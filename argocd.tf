resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.11"
  timeout          = 600
  wait             = false
  atomic           = false

  depends_on = [module.eks, helm_release.alb_controller]

  values = [
    <<-EOT
    configs:
      params:
        server.insecure: "true"
        server.rootpath: "/argocd"
    server:
      extraArgs:
        - --insecure
        - --rootpath=/argocd
    EOT
  ]
}

resource "kubernetes_ingress_v1" "argocd" {
  metadata {
    name      = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/group.name"       = "sportsstore"
      "alb.ingress.kubernetes.io/group.order"      = "10"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/argocd/healthz"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "sportsstore.seansite.org"
      http {
        path {
          path      = "/argocd"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.argocd, helm_release.alb_controller]
}
