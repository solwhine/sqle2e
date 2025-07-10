CREATE TABLE [dev].[MarginAuditLog]
(
[auditID] [int] NOT NULL IDENTITY(1, 1),
[vendorID] [int] NULL,
[vendorName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[productID] [int] NULL,
[productName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[quantity] [int] NULL,
[costPrice] [decimal] (10, 2) NULL,
[listPrice] [decimal] (10, 2) NULL,
[marginPercent] [decimal] (5, 2) NULL,
[saleDate] [date] NULL,
[loggedAt] [datetime2] NULL CONSTRAINT [DF__MarginAud__logge__7B113988] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [dev].[MarginAuditLog] ADD CONSTRAINT [PK__MarginAu__43D173F9777A32D1] PRIMARY KEY CLUSTERED ([auditID]) ON [PRIMARY]
GO
