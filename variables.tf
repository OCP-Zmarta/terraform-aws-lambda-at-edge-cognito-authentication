# ================================================================================================================
# General Configurations
# ================================================================================================================

variable "name" {
  description = "Name to prefix on all infrastructure created by this module."
  type        = string
}

variable "tags" {
  description = "Map of tags to attach to all AWS resources created by this module."
  type        = map(string)
  default     = {}
}

# ================================================================================================================
# Cloudwatch Configurations
# ================================================================================================================

variable "cloudwatch_enable_log_group_create" {
  description = "Allow Lambda@Edge to create log groups in cloudwatch, defaults to true."
  type        = bool
  default     = true
}

# ================================================================================================================
# Lambda Configurations
# ================================================================================================================

variable "lambda_runtime" {
  description = "Lambda runtime to utilize for Lambda@Edge."
  type        = string
  default     = "nodejs20.x"
}

variable "lambda_timeout" {
  description = "Amount of timeout in seconds to set on for Lambda@Edge."
  type        = number
  default     = 5
}

variable "lambda_config_mode" {
  description = "Which strategy to use to supply config to the lambda function, defaults to 'static'."
  type        = string
  default     = "static"
  validation {
    condition     = contains(["dynamic", "hybrid", "static"], var.lambda_config_mode)
    error_message = "Input var.lambda_config_mode must be one of \"dynamic\", \"hybrid\", \"static\"."
  }
}

variable "lambda_config_allow_insecure_secret_storage" {
  description = "Allow secrets to be stored in the lambda config file, defaults to true."
  type        = bool
  default     = true
}

# ================================================================================================================
# Cognito @ Edge Configurations
# ================================================================================================================

variable "cognito_user_pool_name" {
  description = "Name of the Cognito User Pool to utilize. Required if 'cognito_user_pool_domain' is not set."
  type        = string
  default     = ""
}

variable "cognito_user_pool_domain" {
  description = "Optional: Full Domain of the Cognito User Pool to utilize. Mutually exclusive with 'cognito_user_pool_name'."
  type        = string
  default     = ""
}

variable "cognito_user_pool_region" {
  description = "AWS region where the cognito user pool was created."
  type        = string
  default     = "us-west-2"
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for the targeted user pool."
  type        = string
}

variable "cognito_user_pool_app_client_id" {
  description = "Cognito User Pool App Client ID for the targeted user pool."
  type        = string
}

variable "cognito_user_pool_app_client_secret" {
  description = "Cognito User Pool App Client Secret for the targeted user pool. NOTE: This is currently not compatible with AppSync applications."
  type        = string
  default     = null
}

variable "cognito_cookie_expiration_days" {
  description = "Number of days to keep the cognito cookie valid."
  type        = number
  default     = 7
}

variable "cognito_disable_cookie_domain" {
  description = "Sets domain attribute in cookies, defaults to false."
  type        = bool
  default     = false
}

variable "cognito_log_level" {
  description = "Logging level. Default: 'silent'"
  type        = string
  default     = "silent"

  validation {
    condition     = contains(["fatal", "error", "warn", "info", "debug", "trace", "silent"], var.cognito_log_level)
    error_message = "Cognito Log Level must be one of: ['fatal', 'error', 'warn', 'info', 'debug', 'trace', 'silent']."
  }
}

variable "cognito_redirect_path" {
  description = "Optional path to redirect to after a successful cognito login."
  type        = string
  default     = ""
}

variable "cognito_http_only" {
  description = "Sets HttpOnly flag on cookies to prevent JavaScript access (recommended for security). Note: If true, cookies won't be accessible to AWS Amplify client-side."
  type        = bool
  default     = true
}

variable "cognito_same_site" {
  description = "Sets SameSite attribute for cookies. Options: 'Strict', 'Lax', or 'None'. 'Lax' is recommended for most use cases."
  type        = string
  default     = "Lax"

  validation {
    condition     = contains(["Strict", "Lax", "None"], var.cognito_same_site)
    error_message = "cognito_same_site must be one of: 'Strict', 'Lax', or 'None'."
  }
}

variable "cognito_cookie_path" {
  description = "Sets Path attribute for cookies. Defaults to '/' to make authentication cookies available site-wide. Use a specific path like '/app' to restrict cookies to that path only."
  type        = string
  default     = "/"
}

variable "cognito_csrf_protection_enabled" {
  description = "Enable CSRF protection. Highly recommended for production environments."
  type        = bool
  default     = true
}

variable "cognito_refresh_token_expiration_days" {
  description = "Number of days for refresh token cookie expiration. Should match Cognito User Pool refresh token validity."
  type        = number
  default     = 7
}

variable "cognito_access_token_expiration_days" {
  description = "Number of days for access token cookie expiration. Should match Cognito User Pool access token validity. Use fractional days for hours (e.g., 0.041666666 for 60 minutes)."
  type        = number
  default     = 0.041666666 # 60 minutes
}

variable "cognito_id_token_expiration_days" {
  description = "Number of days for ID token cookie expiration. Should match Cognito User Pool ID token validity. Use fractional days for hours (e.g., 0.041666666 for 60 minutes)."
  type        = number
  default     = 0.041666666 # 60 minutes
}

variable "cognito_additional_settings" {
  description = "Map of any to configure any additional cognito@edge parameters not handled by this module."
  type        = any
  default     = {}
}
