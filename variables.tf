/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "project_id" {
  description = "gcp project ID"
  type        = string
}

variable "name" {
  description = "name prefix for resources"
  type        = string
}

variable "regions" {
  type        = list(string)
  description = "deploy to regions"

  /*

    Ideally this should come from a data source:
        https://github.com/hashicorp/terraform-provider-google/issues/7850

    Until then, Cloud Run Regions list can be obtained from the REST API:

        curl -sSLfH "Authorization: Bearer $(gcloud auth print-access-token -q)" \
            "https://run.googleapis.com/v1/projects/$(gcloud config get-value core/project -q)/locations?alt=json" |\
            jq '[.locations[].locationId]'
    */
  default = [
    "asia-east1",
    "asia-east2",
    "asia-northeast1",
    "asia-northeast2",
    "asia-northeast3",
    "asia-south1",
    "asia-southeast1",
    "asia-southeast2",
    "australia-southeast1",
    "europe-north1",
    "europe-west1",
    "europe-west2",
    "europe-west3",
    "europe-west4",
    "europe-west6",
    "northamerica-northeast1",
    "southamerica-east1",
    "us-central1",
    "us-east1",
    "us-east4",
    "us-west1"
  ]
}

variable "image" {
  description = "container image to deploy"
  default     = "gcr.io/ahmetb-public/zoneprinter"
}
