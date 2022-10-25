# Boundary provider declaration
provider "boundary"{
  addr                            = "http://127.0.0.1:9200"
  auth_method_id                  = "ampw_1234567890"
  password_auth_method_login_name = "admin"
  password_auth_method_password   = "password"
}

resource "boundary_scope" "global" {
  global_scope = true
  description  = "My first global scope!"
  scope_id     = "global"
}

resource "boundary_scope" "boundary_demo"{
    name = "boundary_demo"
    description = "My first boundary demo scope"
    scope_id = boundary_scope.global.id
    auto_create_admin_role = true
    auto_create_default_role = true
}

resource "boundary_auth_method" "password"{
    name = "password auth"
    scope_id = boundary_scope.boundary_demo.id
    type = "password"
}

resource "boundary_auth_method_oidc" "provider"{
 name = "oidc"
 description = "oidc auth method"
 scope_id = boundary_scope.boundary_demo.id
 issuer = "http://localhost:8080/realms/naitech"
 client_id = "boundary-demo"
 client_secret = "B5txgyM8lsU64FBfhh2VAgylW6nRvs8B"
 signing_algorithms = ["RS256"]
 api_url_prefix = "http://localhost:9200"
}


resource "boundary_managed_group" "boundary-demo-grp"{
  name =  "boundary-group-demo"
  description = "An example of OIDC managed group"
  auth_method_id = boundary_auth_method_oidc.provider.id
  filter = "\"naitech-boundary-demo\" in \"/token/groups\""
}


resource "boundary_role" "boundary-demo-role"{
  name = "boundary-demo-role"
  description = "Assign admin rights"
  principal_ids = [boundary_managed_group.boundary-demo-grp.id]
  grant_strings = ["id=*;type=*;actions=*"]
  scope_id = boundary_scope.boundary_demo.id
}

resource "boundary_managed_group" "boundary-demo-grp-read"{
  name =  "boundary-group-demo-read"
  description = "An example of OIDC managed group"
  auth_method_id = boundary_auth_method_oidc.provider.id
  filter = "\"naitech-boundary-demo-read\" in \"/token/groups\""
}


resource "boundary_role" "boundary-demo-role-read"{
  name = "boundary-demo-role-read"
  description = "Assign readonly rights"
  principal_ids = [boundary_managed_group.boundary-demo-grp-read.id]
  grant_strings = ["id=*;type=*;actions=list,read"]
  scope_id = boundary_scope.boundary_demo.id
}