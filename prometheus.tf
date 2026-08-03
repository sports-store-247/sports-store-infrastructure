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
          domain: grafana.seansite.org
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
      "alb.ingress.kubernetes.io/healthcheck-path" = "/api/health"
      "alb.ingress.kubernetes.io/certificate-arn"  = "arn:aws:acm:us-east-1:765858872029:certificate/9b33a59c-3ac2-47b7-a2f7-6373887377e3"
      "alb.ingress.kubernetes.io/listen-ports"     = "[{\"HTTPS\":443}, {\"HTTP\":80}]"
      "alb.ingress.kubernetes.io/ssl-redirect"     = "443"
    }
  }

  spec {
    ingress_class_name = "alb"

    rule {
      host = "grafana.seansite.org"
      http {
        path {
          path      = "/"
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
