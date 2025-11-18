locals {
  lambda_configuration = jsonencode(merge({
    region               = var.cognito_user_pool_region
    userPoolId           = var.cognito_user_pool_id
    userPoolAppId        = var.cognito_user_pool_app_client_id
    userPoolAppSecret    = var.cognito_user_pool_app_client_secret == null ? "" : var.cognito_user_pool_app_client_secret
    userPoolDomain       = coalesce(var.cognito_user_pool_domain, "${var.cognito_user_pool_name}.auth.${var.cognito_user_pool_region}.amazoncognito.com")
    cookieExpirationDays = var.cognito_cookie_expiration_days
    disableCookieDomain  = var.cognito_disable_cookie_domain
    logLevel             = var.cognito_log_level
    parseAuthPath        = var.cognito_redirect_path
    httpOnly             = var.cognito_http_only
    sameSite             = var.cognito_same_site
    cookiePath           = var.cognito_cookie_path
    csrfProtection = var.cognito_csrf_protection_enabled ? {
      nonceSigningSecret = random_password.csrf_secret[0].result
    } : null
    cookieSettingsOverrides = {
      refreshToken = {
        expirationDays = var.cognito_refresh_token_expiration_days
      }
      accessToken = {
        expirationDays = var.cognito_access_token_expiration_days
      }
      idToken = {
        expirationDays = var.cognito_id_token_expiration_days
      }
    }
  }, var.cognito_additional_settings))

  # if config_mode is not 'static' (ie 'dynamic' or 'hybrid') then we need to create the SSM parameter
  create_ssm_parameter = var.lambda_config_mode != "static" ? true : false
}

# Generate a random secret for CSRF protection
resource "random_password" "csrf_secret" {
  count = var.cognito_csrf_protection_enabled ? 1 : 0

  length  = 64
  special = true
  upper   = true
  lower   = true
  numeric = true

  lifecycle {
    ignore_changes = [
      length,
      special,
      upper,
      lower,
      numeric,
    ]
  }
}

resource "aws_kms_key" "ssm_kms_key" {
  count                   = local.create_ssm_parameter ? 1 : 0
  description             = "KMS Encryption key for ${var.name} lambda-edge auth"
  deletion_window_in_days = 7
  tags                    = var.tags
  enable_key_rotation     = true
}

resource "aws_ssm_parameter" "lambda_configuration_parameters" {
  count       = local.create_ssm_parameter ? 1 : 0
  name        = "/${var.name}/lambda/edge/configuration"
  description = "Lambda@Edge Configuration for Application[${var.name}]"
  type        = "SecureString"
  key_id      = aws_kms_key.ssm_kms_key[0].key_id
  value       = local.lambda_configuration
  tags        = var.tags
}
