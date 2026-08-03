resource "helm_release" "prometheus" {
  name             = "prometheus"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "58.1.3"
  timeout          = 600

  depends_on = [module.eks, helm_release.alb_controller]

  values = [
    <<-EOT
    defaultRules:
      create: true
    alertmanager:
      enabled: true
    kubeStateMetrics:
      enabled: true
    nodeExporter:
      enabled: true

    prometheus:
      prometheusSpec:
        retention: 12h
        resources:
          requests:
            memory: 256Mi
            cpu: 50m
          limits:
            memory: 512Mi

    grafana:
      adminPassword: "sports-store-secure-grafana-password"
      resources:
        requests:
          memory: 64Mi
          cpu: 50m
        limits:
          memory: 128Mi
      
      grafana.ini:
        server:
          root_url: "%(protocol)s://%(domain)s/grafana"
          serve_from_sub_path: true
    EOT
  ]
}

resource "kubernetes_ingress_v1" "grafana" {
  metadata {
    name      = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "alb.ingress.kubernetes.io/scheme"           = "internet-facing"
      "alb.ingress.kubernetes.io/target-type"      = "ip"
      "alb.ingress.kubernetes.io/group.name"       = "sportsstore"
      "alb.ingress.kubernetes.io/group.order"      = "15"
      "alb.ingress.kubernetes.io/healthcheck-path" = "/grafana/api/health"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      http {
        path {
          path      = "/grafana"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-grafana"
              port { number = 80 }
            }
          }
        }
      }
    }
  }

  depends_on = [helm_release.prometheus, helm_release.alb_controller]
}
