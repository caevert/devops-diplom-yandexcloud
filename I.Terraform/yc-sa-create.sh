#! /bin/bash
yc iam service-account create --name bucketbot
yc resource-manager folder add-access-binding b1g96o71ipj82qfd6304 \
  --role <role-id> \
  --subject serviceAccount:<service-account-id>


  fd8e5oous6ulsjrcclqf