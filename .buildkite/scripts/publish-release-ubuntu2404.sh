#!/bin/bash

set -ex

# Get release version
RELEASE_VERSION=$(buildkite-agent meta-data get release-version 2>/dev/null | sed 's/^v//')
if [ -z "${RELEASE_VERSION}" ]; then
  echo "ERROR: release-version metadata not found"
  exit 1
fi

COMMIT="$BUILDKITE_COMMIT"

# Login to ECR
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws/q9t5s3a7

# Pull ubuntu2404 images from ECR
docker pull public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-ubuntu2404
docker pull public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-ubuntu2404
docker pull public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-cu130-ubuntu2404
docker pull public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-cu130-ubuntu2404

# Tag and push CUDA 12.9 ubuntu2404 images
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-ubuntu2404
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-ubuntu2404 vllm/vllm-openai:latest-x86_64-ubuntu2404
docker push vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-ubuntu2404
docker push vllm/vllm-openai:latest-x86_64-ubuntu2404

docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-ubuntu2404
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-ubuntu2404 vllm/vllm-openai:latest-aarch64-ubuntu2404
docker push vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-ubuntu2404
docker push vllm/vllm-openai:latest-aarch64-ubuntu2404

# Tag and push CUDA 13.0 ubuntu2404 images
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-cu130-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-cu130-ubuntu2404
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-x86_64-cu130-ubuntu2404 vllm/vllm-openai:latest-x86_64-cu130-ubuntu2404
docker push vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-cu130-ubuntu2404
docker push vllm/vllm-openai:latest-x86_64-cu130-ubuntu2404

docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-cu130-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-cu130-ubuntu2404
docker tag public.ecr.aws/q9t5s3a7/vllm-release-repo:${COMMIT}-aarch64-cu130-ubuntu2404 vllm/vllm-openai:latest-aarch64-cu130-ubuntu2404
docker push vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-cu130-ubuntu2404
docker push vllm/vllm-openai:latest-aarch64-cu130-ubuntu2404

# Create and push multi-arch manifests - CUDA 12.9 ubuntu2404
docker manifest rm vllm/vllm-openai:latest-ubuntu2404 || true
docker manifest create vllm/vllm-openai:latest-ubuntu2404 vllm/vllm-openai:latest-x86_64-ubuntu2404 vllm/vllm-openai:latest-aarch64-ubuntu2404
docker manifest push vllm/vllm-openai:latest-ubuntu2404
docker manifest create vllm/vllm-openai:v${RELEASE_VERSION}-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-ubuntu2404
docker manifest push vllm/vllm-openai:v${RELEASE_VERSION}-ubuntu2404

# Create and push multi-arch manifests - CUDA 13.0 ubuntu2404
docker manifest rm vllm/vllm-openai:latest-cu130-ubuntu2404 || true
docker manifest create vllm/vllm-openai:latest-cu130-ubuntu2404 vllm/vllm-openai:latest-x86_64-cu130-ubuntu2404 vllm/vllm-openai:latest-aarch64-cu130-ubuntu2404
docker manifest push vllm/vllm-openai:latest-cu130-ubuntu2404
docker manifest create vllm/vllm-openai:v${RELEASE_VERSION}-cu130-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-x86_64-cu130-ubuntu2404 vllm/vllm-openai:v${RELEASE_VERSION}-aarch64-cu130-ubuntu2404
docker manifest push vllm/vllm-openai:v${RELEASE_VERSION}-cu130-ubuntu2404
