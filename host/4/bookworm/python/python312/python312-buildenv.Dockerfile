#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License. See https://go.microsoft.com/fwlink/?linkid=2090316 for license information.
#-------------------------------------------------------------------------------------------------------------

FROM mcr.microsoft.com/oryx/python:3.12-debian-bookworm

ENV LANG=C.UTF-8 \
    ACCEPT_EULA=Y \
    AzureWebJobsScriptRoot=/home/site/wwwroot \
    HOME=/home \
    FUNCTIONS_WORKER_RUNTIME=python \
    ASPNETCORE_URLS=http://+:80 \
    DOTNET_RUNNING_IN_CONTAINER=true \
    DOTNET_USE_POLLING_FILE_WATCHER=true

# Install Python dependencies
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg && \
    apt-get update && \
    apt-get install -y wget apt-transport-https curl gnupg2 locales && \
    echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo "deb [arch=amd64] https://packages.microsoft.com/debian/12/prod bookworm main" | tee /etc/apt/sources.list.d/mssql-release.list && \
    # Needed for libss3 and in turn MS SQL
    echo 'deb http://security.debian.org/debian-security bookworm-security main' >> /etc/apt/sources.list && \
    curl https://packages.microsoft.com/config/debian/12/prod.list | tee /etc/apt/sources.list.d/mssql-release.list && \
    # install MS SQL related packages.pinned version in PR # 1012.
    echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen && \
    locale-gen && \
    apt-get update && \
    # MS SQL related packages: unixodbc msodbcsql18 mssql-tools
    ACCEPT_EULA=Y apt-get install -y unixodbc msodbcsql18 mssql-tools18 && \
    # OpenCV dependencies:libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb && \
    # .NET Core dependencies: ca-certificates libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g 
    # Azure ML dependencies: liblttng-ust0
    # OpenMP dependencies: libgomp1
    # binutils: binutils
    apt-get install -y --no-install-recommends ca-certificates \
    libc6 libgcc1 libgssapi-krb5-2 libicu72 libssl3 libstdc++6 zlib1g && \
    apt-get install -y libglib2.0-0 libsm6 libxext6 libxrender-dev xvfb binutils \
    libgomp1 liblttng-ust1 && \
    rm -rf /var/lib/apt/lists/* 

RUN apt-get update && \
    apt-get install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev \
    xz-utils tk-dev libffi-dev liblzma-dev python3-openssl git unixodbc-dev dh-autoreconf \
    libcurl4-openssl-dev libssl-dev python3-dev libevent-dev python3-openssl squashfs-tools unzip

