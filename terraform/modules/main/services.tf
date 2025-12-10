locals {
  service = toset([
    # デフォルトで有効
    # デフォルトで有効なAPIは以下参照
    # https://cloud.google.com/service-usage/docs/enabled-service?hl=ja#defa
    "bigquery.googleapis.com", # BigQuery API / Cloud Guard用
    "bigquerymigration.googleapis.com", # BigQuery Migration API
    "bigquerystorage.googleapis.com", # BigQuery Storage API
    "datastore.googleapis.com", # Cloud Datastore API
    "logging.googleapis.com", # Cloud Logging API / Cloud Guard用
    "monitoring.googleapis.com", # Cloud Monitoring API
    "sql-component.googleapis.com", # Cloud SQL
    "storage-component.googleapis.com", # Cloud Storage
    "storage.googleapis.com", # Cloud Storage API
    "cloudtrace.googleapis.com", # Cloud Trace API
    "cloudapis.googleapis.com", # Google Cloud API
    "storage-api.googleapis.com", # Google Cloud Storage JSON API
    "servicemanagement.googleapis.com", # Service Management API
    "serviceusage.googleapis.com", # Service Usage API / Cloud Guard用

    # 要件定義書記載
    "compute.googleapis.com", # Compute Engine API / Cloud Guard用
    "iap.googleapis.com", # Cloud Identity-Aware Proxy API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API / Cloud Guard用
    "cloudbilling.googleapis.com", # Cloud Billing API
    "cloudasset.googleapis.com", # Cloud Asset API / Cloud Guard用
    "iam.googleapis.com",# Identity and Access Management (IAM) API / Cloud Guard用

    # Cloud Guard用
    "container.googleapis.com", # Kubernetes Engine API
    "cloudkms.googleapis.com", # Cloud Key Management Service (KMS) API
    "admin.googleapis.com", # Admin SDK API
    "cloudfunctions.googleapis.com", # Cloud Functions API
    "sqladmin.googleapis.com", # Cloud SQL Admin API
    "apikeys.googleapis.com", # API Keys API
    "dns.googleapis.com", # Cloud DNS API
    "accessapproval.googleapis.com", # Access Approval API
    "pubsub.googleapis.com", # Cloud Pub/Sub API
    "artifactregistry.googleapis.com", # Cloud artifact_registry API
    "cloudbuild.googleapis.com", # Cloud build_registry API
    "vpcaccess.googleapis.com", # vpcaccess API

    # Google Maps Platform
    "airquality.googleapis.com", # Air Quality API
    "solar.googleapis.com", # Solar API
    "aerialview.googleapis.com", # Aerial View API
    "tile.googleapis.com", # Map Tiles API
    "mapsplatformdatasets.googleapis.com", # Maps Datasets API
    "elevation-backend.googleapis.com", # Maps Elevation API
    "maps-embed-backend.googleapis.com", # Maps Embed API
    "maps-backend.googleapis.com", # Maps JavaScript API
    "maps-android-backend.googleapis.com", # Maps SDK for Android
    "maps-ios-backend.googleapis.com", # Maps SDK for iOS
    "static-maps-backend.googleapis.com", # Maps Static API
    "streetviewpublish.googleapis.com", # Street View Publish API
    "street-view-image-backend.googleapis.com", # Street View Static API
    "addressvalidation.googleapis.com", # Address Validation API
    "geocoding-backend.googleapis.com", # Geocoding API
    "geolocation.googleapis.com", # Geolocation API
    "places-backend.googleapis.com", # Places API
    "places.googleapis.com", # Places API (New)
    "timezone-backend.googleapis.com", # Time Zone API
    "directions-backend.googleapis.com", # Directions API
    "distance-matrix-backend.googleapis.com", # Distance Matrix API
    "roads.googleapis.com", # Roads API
    "routes.googleapis.com" # Routes API
  ])
}

resource "google_project_service" "main" {
  project  = split("/", google_project.main.id)[1]
  for_each = local.service
  service  = each.value

  disable_on_destroy = true
}