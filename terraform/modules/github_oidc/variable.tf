variable "github_repo" {
  description = "GitHub repository in format org/repo"
  type        = string
}

variable "github_branch" {
  description = "Branch to allow for assume role (e.g., main)"
  type        = string
  default     = "main"
}

variable "role_name" {
  description = "IAM Role name for GitHub Actions"
  type        = string
  default     = "github-actions-deploy-role"
}

variable "policy_arn" {
  description = "IAM policy to attach to GitHub Actions role"
  type        = string
  default     = "arn:aws:iam::aws:policy/AdministratorAccess"
}
