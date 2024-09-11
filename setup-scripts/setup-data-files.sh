#!/bin/bash
# ./setup-data-files.sh your-project-id https://github.com/your-username/your-repo.git unique-id

# Check if project ID, repo URL, and unique ID are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Error: Please provide GCP project ID, GitHub repository URL, and a unique ID as arguments."
    echo "Usage: ./upload_to_gcs.sh <project-id> <github-repo-url> <unique-id>"
    exit 1
fi

PROJECT_ID="$1"
REPO_URL="$2"
REPO_NAME=$(basename "$REPO_URL" .git) # Extract repo name from URL
UNIQUE_ID="$3"
BASE_BUCKET="hazmat-data-files-${UNIQUE_ID}"
DATA_FILES_DIR="data-files" # Added this line

# 1. Clone the GitHub Repository
git clone "$REPO_URL"

# 2. Navigate to the Repository
cd "$REPO_NAME"

# 3. Install the Google Cloud SDK (if not already installed)
if ! command -v gcloud &> /dev/null
then
    echo "Google Cloud SDK not found. Please install it first."
    exit 1
fi

# 4. Authenticate with Google Cloud
#gcloud auth login

# 5. Set Your Project
gcloud config set project "$PROJECT_ID"

# 6. Create the Base Bucket
if gsutil ls -b gs://${BASE_BUCKET} &> /dev/null; then # Check if bucket exists
    echo "Error: Bucket gs://${BASE_BUCKET} already exists. Please choose a different unique ID or delete the existing bucket."
    exit 1
else
    gsutil mb gs://${BASE_BUCKET}
fi

# 7. Upload Files to Folders within the Base Bucket (updated to include data-files)
for folder in hazmat-pictograms hazmat-pictograms-embeddings hazmat-pictograms-descriptions hazmat-prod hazmat-prod-embeddings hazmat-sds hazmat-sds-embeddings hazmat-wsg hazmat-wsg-embeddings; do
    echo "Uploading $folder..."
    gsutil -m cp -r ${DATA_FILES_DIR}/$folder gs://${BASE_BUCKET}/${folder} 
done

echo "Upload complete!"