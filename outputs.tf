output "load_balancer_ip" {
  description = "Display load balancer IP"
  value       = kubernetes_ingress_v1.nginx-example.status.0.load_balancer.0.ingress.0.ip
}
