# Make an alias for Microsoft's SQL Server Images
# For x64, use SQL Server 2019 because it supports more things
# like HA. For ARM, use SQL Server Edge because SQL Server 2019 doesn't have an ARM image.
# Linux supported features: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-editions-and-components-2019
# Edge supported features: https://docs.microsoft.com/en-us/azure/azure-sql-edge/features

FROM --platform=amd64 mcr.microsoft.com/mssql/server:2019-latest