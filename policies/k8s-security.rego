package k8s.security

import rego.v1

# Deny containers running as root
violation contains msg if {
	some container in input.spec.containers
	not container.securityContext.runAsNonRoot
	msg := sprintf("Container '%s' must set securityContext.runAsNonRoot to true", [container.name])
}

# Deny containers without resource limits
violation contains msg if {
	some container in input.spec.containers
	not container.resources.limits
	msg := sprintf("Container '%s' must define resource limits", [container.name])
}

# Deny containers with privileged mode
violation contains msg if {
	some container in input.spec.containers
	container.securityContext.privileged
	msg := sprintf("Container '%s' must not run in privileged mode", [container.name])
}

# Deny images using :latest tag
violation contains msg if {
	some container in input.spec.containers
	endswith(container.image, ":latest")
	msg := sprintf("Container '%s' must not use ':latest' image tag", [container.name])
}

# Deny containers without readOnlyRootFilesystem
violation contains msg if {
	some container in input.spec.containers
	not container.securityContext.readOnlyRootFilesystem
	msg := sprintf("Container '%s' should set readOnlyRootFilesystem to true", [container.name])
}
