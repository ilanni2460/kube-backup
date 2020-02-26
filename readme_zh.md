# 项目介绍

以 git 项目备份 kubernetes resource 的一个工具，建议以 CronJob 形式运行

# 使用方式

打包镜像 `kube-backup:latest`

准备一个secret，用于拉取仓库（我这里用的是pull-gitlab）

配置“期望值”:
我这里配置的是每隔十分钟自动同步到 `ssh://git@192.168.33.33:666/ci/kubernetes-backup.git` 这个仓库，备份的 namespace 有`ahas argo catalog default test kubeflow`，备份的资源类型为`ingress deployment configmap svc rc ds  statefulset secret
 cronjob`

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  labels:
    app: kube-backup
  name: kube-backup
  namespace: default
spec:
  concurrencyPolicy: Replace
  failedJobsHistoryLimit: 0
  jobTemplate:
    metadata: {}
    spec:
      template:
        metadata:
          labels:
            app: kube-backup
          name: kube-backup
        spec:
          containers:
            - env:
                - name: GIT_REPO
                  value: 'ssh://git@192.168.33.33:666/ci/kubernetes-backup.git'
                - name: RESOURCETYPES
                  value: >-
                    ingress deployment configmap svc rc ds  statefulset secret
                    cronjob
                - name: NAMESPACES
                  value: ahas argo catalog default test kubeflow
              image: 'kube-backup:latest'
              imagePullPolicy: IfNotPresent
              name: backup
              resources: {}
              terminationMessagePath: /dev/termination-log
              terminationMessagePolicy: File
              volumeMounts:
                - mountPath: /root
                  name: cache
                - mountPath: /root/.ssh
                  name: sshkey
          dnsPolicy: ClusterFirst
          restartPolicy: Never
          schedulerName: default-scheduler
          securityContext: {}
          serviceAccount: kube-backup
          serviceAccountName: kube-backup
          terminationGracePeriodSeconds: 30
          volumes:
            - emptyDir: {}
              name: cache
            - name: sshkey
              secret:
                defaultMode: 256
                secretName: pull-gitlab
  schedule: '*/10 * * * *'
  successfulJobsHistoryLimit: 3
  suspend: false

```
