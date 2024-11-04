variable "DEFAULT_TAG" {
  default = "flexget:latest"
}

group "default" {
  targets = ["local"]
}

target "local" {
  tags = ["${DEFAULT_TAG}"]
  output = ["type=docker"]
}

target "docker-metadata-action" {}

target "all" {
  inherits = ["docker-metadata-action"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}
