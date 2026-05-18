# Troubleshooting

## ERR-01 — K8sVersionNotSupported

**Error:** `Managed cluster is on version 1.29.x which is not supported in this region`
**Causa:** Azure depreca minor versions por región sin aviso previo.
**Fix:** `az aks get-versions --location <region> --output table` → usar última patch de minor más reciente sin IsPreview.
**Prevención:** Consultar versiones disponibles antes de fijar `kubernetes_version` en tfvars.

---

## ERR-02 — Helm pre/post install hook timeout (Pending pods)

**Error:** `timed out waiting for the condition` en `helm install`
**Causa:** Node pools con taints personalizados rechazan pods de charts de terceros que no incluyen tolerations por defecto. Afecta a Jobs de admission webhooks y startupapicheck — componentes que los charts de terceros no documentan prominentemente.
**Síntoma:** Pod en `Pending` con evento: `0/3 nodes available: 1 node(s) had untolerated taint {workload: user}`
**Fix:** Pasar tolerations explícitos a TODOS los subcomponentes del chart:
- ingress-nginx: `controller.tolerations` + `controller.admissionWebhooks.patch.tolerations`
- cert-manager: `tolerations` + `webhook.tolerations` + `cainjector.tolerations` + `startupapicheck.tolerations`
**Prevención:** Cuando uses taints en node pools, siempre audita los subcomponentes de cada chart con `helm show values <chart> | grep -A5 tolerations`.
