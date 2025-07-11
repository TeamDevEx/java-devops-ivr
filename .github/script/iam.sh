#!/bin/bash

# Enable color output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Config
PROJECT_ID="off-net-dev"
REGION="northamerica-northeast1"
ZONE="northamerica-northeast1-a"
SERVICE_ACCOUNT_NAME="java-devops-ivr"
SERVICE_ACCOUNT_EMAIL="$SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com"
BUCKET_PUBSUB_RESPONSE="java-devops-ivr"
TF_BUCKET_STATE="tf-state-java-devops-ivr"
TOPIC_NAME="java-devops-ivr-topic"
SUBSCRIPTION_NAME="java-devops-ivr-sub"

# Step 1: Create Service Account
echo -e "${YELLOW}🔧 Creating service account: ${SERVICE_ACCOUNT_NAME}${NC}"
gcloud iam service-accounts create "$SERVICE_ACCOUNT_NAME" \
  --description="Service Account for IVR Java Demo" \
  --display-name="IVR Demo Service Account" \
  --project="$PROJECT_ID"

# Step 2: Assign-Bind Roles
echo -e "${YELLOW}🔐 Granting IAM roles to the service account...${NC}"
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/pubsub.publisher"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/pubsub.subscriber"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/storage.objectCreator"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/artifactregistry.writer"

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/container.developer" 

gcloud projects add-iam-policy-binding "$PROJECT_ID" \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/storage.admin"   

gcloud projects add-iam-policy-binding off-net-dev \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/container.clusterAdmin"

gcloud projects add-iam-policy-binding off-net-dev \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/iam.serviceAccountUser"

gcloud projects add-iam-policy-binding off-net-dev \
  --member="serviceAccount:$SERVICE_ACCOUNT_EMAIL" \
  --role="roles/compute.viewer"  

gcloud storage buckets create my-secure-bucket \
    --location=asia-southeast1 \
    --class=STANDARD \
    --uniform-bucket-level-access

gcloud storage buckets create gs://$BUCKET_PUBSUB_RESPONSE 
    --default-storage-class=standard 
    --location=$REGION

gcloud storage buckets create gs://$TF_BUCKET_STATE 
    --default-storage-class=standard 
    --location=$REGION

# Step 4: Create Pub/Sub Topic
echo -e "${YELLOW}📨 Creating Pub/Sub topic: ${TOPIC_NAME}${NC}"
gcloud pubsub topics create "$TOPIC_NAME" --project="$PROJECT_ID"

# Step 5: Create Pub/Sub Subscription
echo -e "${YELLOW}📬 Creating Pub/Sub subscription: ${SUBSCRIPTION_NAME}${NC}"
gcloud pubsub subscriptions create "$SUBSCRIPTION_NAME" \
  --topic="$TOPIC_NAME" \
  --ack-deadline=30 \
  --project="$PROJECT_ID"

# Create WIF
gcloud iam workload-identity-pools create java-ivr-wif-pool --location="global" --project off-net-dev  

## Repo level only attribute  
gcloud iam workload-identity-pools providers create-oidc java-ivr-provider \
  --location="global" \
  --workload-identity-pool="java-ivr-wif-pool" \
  --issuer-uri="https://token.actions.githubusercontent.com/" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --attribute-condition="attribute.repository == 'TeamDevEx/java-devops-ivr'" \
  --project="off-net-dev"


# Bind repo project SA to WIF
gcloud iam service-accounts add-iam-policy-binding java-devops-ivr@off-net-dev.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member="principalSet://iam.googleapis.com/projects/541105984323/locations/global/workloadIdentityPools/java-ivr-wif-pool/attribute.repository/TeamDevEx/java-devops-ivr"

## Connect to cluster
gcloud container clusters get-credentials java-ivr-app --region northamerica-northeast1 --project off-net-dev

## create cluster namespace
kubectl create namespace development
kubectl label namespace development \
  "gke.io/managed-by-autopilot"="true" --overwrite

# create gke SA
kubectl create serviceaccount gke-sa -n development

# Annotate GKE-SA/SA
kubectl annotate serviceaccount gke-sa \
  --namespace=development \
  iam.gke.io/gcp-service-account=java-devops-ivr@off-net-dev.iam.gserviceaccount.com

# Bind role
gcloud iam service-accounts add-iam-policy-binding java-devops-ivr@off-net-dev.iam.gserviceaccount.com \
  --role="roles/iam.workloadIdentityUser" \
  --member="serviceAccount:off-net-dev.svc.id.goog[development/gke-sa]"

