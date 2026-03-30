package k8s.security_test

import rego.v1

import data.k8s.security

# --- runAsNonRoot tests ---

test_deny_missing_run_as_non_root if {
	result := security.violation with input as {"spec": {"containers": [
		{"name": "app", "image": "ghcr.io/sample:v1.0.0", "securityContext": {}},
	]}}
	count(result) > 0
}

test_allow_run_as_non_root if {
	result := security.violation with input as {"spec": {"containers": [
		{
			"name": "app",
			"image": "ghcr.io/sample:v1.0.0",
			"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": true},
			"resources": {"limits": {"cpu": "100m", "memory": "128Mi"}},
		},
	]}}
	count(result) == 0
}

# --- Resource limits tests ---

test_deny_missing_resource_limits if {
	result := security.violation with input as {"spec": {"containers": [
		{
			"name": "app",
			"image": "ghcr.io/sample:v1.0.0",
			"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": true},
		},
	]}}
	count(result) > 0
}

# --- Privileged mode tests ---

test_deny_privileged_container if {
	result := security.violation with input as {"spec": {"containers": [
		{
			"name": "app",
			"image": "ghcr.io/sample:v1.0.0",
			"securityContext": {"privileged": true, "runAsNonRoot": true, "readOnlyRootFilesystem": true},
			"resources": {"limits": {"cpu": "100m", "memory": "128Mi"}},
		},
	]}}
	count(result) > 0
}

# --- Latest tag tests ---

test_deny_latest_tag if {
	result := security.violation with input as {"spec": {"containers": [
		{
			"name": "app",
			"image": "ghcr.io/sample:latest",
			"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": true},
			"resources": {"limits": {"cpu": "100m", "memory": "128Mi"}},
		},
	]}}
	count(result) > 0
}

test_allow_pinned_tag if {
	result := security.violation with input as {"spec": {"containers": [
		{
			"name": "app",
			"image": "ghcr.io/sample:v1.0.0",
			"securityContext": {"runAsNonRoot": true, "readOnlyRootFilesystem": true},
			"resources": {"limits": {"cpu": "100m", "memory": "128Mi"}},
		},
	]}}
	count(result) == 0
}
