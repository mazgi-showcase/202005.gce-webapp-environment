resource "google_service_account" "step" {
  account_id = "${var.basename}-step"
}

resource "google_project_iam_member" "step-compute-osadminlogin" {
  role   = "roles/compute.osAdminLogin"
  member = "serviceAccount:${google_service_account.step.email}"
}
