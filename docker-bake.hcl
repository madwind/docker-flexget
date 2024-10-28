variable "DEFAULT_TAG" {
  default = "flexget:latest"
}

target "docker-metadata-action" {
  tags = ["${DEFAULT_TAG}"]
}

group "default" {
  targets = ["local"]
}

target "image" {
  inherits = ["docker-metadata-action"]
}

target "local" {
  inherits = ["image"]
  output = ["type=docker"]
}

target "all" {
  inherits = ["image"]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}