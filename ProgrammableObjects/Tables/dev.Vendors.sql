CREATE TABLE [dev].[Vendors]
(
[vendorID] [int] NOT NULL IDENTITY(1, 1),
[vendorName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[countryCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[createdAt] [datetime2] NULL CONSTRAINT [DF__Vendors__created__6EAB62A3] DEFAULT (sysdatetime())
) ON [PRIMARY]
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [CK__Vendors__country__6DB73E6A] CHECK (([countryCode]='CA' OR [countryCode]='IN' OR [countryCode]='UK' OR [countryCode]='US'))
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [PK__Vendors__EC65C4E3595AD205] PRIMARY KEY CLUSTERED ([vendorID]) ON [PRIMARY]
GO
ALTER TABLE [dev].[Vendors] ADD CONSTRAINT [UQ__Vendors__B20E6930050DCFF3] UNIQUE NONCLUSTERED ([vendorName]) ON [PRIMARY]
GO
