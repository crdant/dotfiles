// Auto-imported filters by 'gmailctl download'.
//
// WARNING: This functionality is experimental. Before making any
// changes, check that no diff is detected with the remote filters by
// using the 'diff' command.

// Uncomment if you want to use the standard library.
// local lib = import 'gmailctl.libsonnet';
{
  version: "v1alpha3",
  author: {
    name: "YOUR NAME HERE (auto imported)",
    email: "your-email@gmail.com"
  },
  // Note: labels management is optional. If you prefer to use the
  // GMail interface to add and remove labels, you can safely remove
  // this section of the config.
  labels: [
    {
      name: "@Follow Up"
    },
    {
      name: "Family"
    },
    {
      name: "Finances"
    },
    {
      name: "Friends"
    },
    {
      name: "Commerce/73 Greenwood"
    },
    {
      name: "History"
    },
    {
      name: "Issues"
    },
    {
      name: "@Waiting For"
    },
    {
      name: "Medford"
    },
    {
      name: "Migrated"
    },
    {
      name: "Notes"
    },
    {
      name: "Sailing"
    },
    {
      name: "Scanning"
    },
    {
      name: "School/CCD"
    },
    {
      name: "School/Lila"
    },
    {
      name: "School/Trey"
    },
    {
      name: "Skating"
    },
    {
      name: "[Gmail]Trash"
    },
    {
      name: "Snipe"
    },
    {
      name: "Soccer"
    },
    {
      name: "Taxes"
    },
    {
      name: "Travel"
    },
    {
      name: "Vacations"
    },
    {
      name: "[Imap]/Drafts"
    },
    {
      name: "Sent Messages"
    },
    {
      name: "Deleted Messages"
    },
    {
      name: "Apple Mail To Do"
    },
    {
      name: "Boomerang-Outbox"
    },
    {
      name: "Wedding"
    },
    {
      name: "[Superhuman]"
    },
    {
      name: "Wellness"
    },
    {
      name: "Bates"
    },
    {
      name: "[Superhuman]/ru"
    },
    {
      name: "[Superhuman]/Is Snoozed"
    },
    {
      name: "[Superhuman]/Muted"
    },
    {
      name: "Melrose"
    },
    {
      name: "Dining"
    },
    {
      name: "Self"
    },
    {
      name: "Paper Trail"
    },
    {
      name: "Swimming"
    },
    {
      name: "Vendors"
    },
    {
      name: "Crosswords"
    },
    {
      name: "News"
    },
    {
      name: "Boat Club"
    },
    {
      name: "Newsletters"
    },
    {
      name: "Commerce"
    },
    {
      name: "Mail"
    },
    {
      name: "Commerce/69 Lynn Fells"
    },
    {
      name: "Commerce/Chuck Car 2008"
    },
    {
      name: "Skeptoid"
    }
  ],
  rules: [
    {
      filter: {
        from: "do_not_reply@itunes.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "supportboston@uber.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "nationalgrid-onlineservice@us.ngrid.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "americanexpress@email4.americanexpress.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "secretary@medfordboatclub.org",
        isEscaped: true
      },
      actions: {
        labels: [
          "Boat Club"
        ]
      }
    },
    {
      filter: {
        from: "service@paypal.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "digital-no-reply@amazon.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "support@thelevelup.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "auto-confirm@amazon.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "ship-confirm@amazon.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "ticketservices@amrep.org"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "anntaylorcard@info.comenity.net"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "noreply-bpt@brownpapertickets.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "pkginfo@ups.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "orders@eventbrite.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        query: "list:email.superhuman.com"
      },
      actions: {
        markSpam: false,
        markImportant: true,
        category: "personal"
      }
    },
    {
      filter: {
        from: "\"HBOMax@mail.hbomax.com\"",
        isEscaped: true
      },
      actions: {
        delete: true
      }
    },
    {
      filter: {
        from: "\"contact@t-shirtslove12.store\"",
        isEscaped: true
      },
      actions: {
        delete: true
      }
    },
    {
      filter: {
        from: "revadmin.no-reply@mbta.com"
      },
      actions: {
        category: "personal"
      }
    },
    {
      filter: {
        from: "\"lfdoherty@aol.com\"",
        isEscaped: true
      },
      actions: {
        delete: true
      }
    },
    {
      filter: {
        from: "jhaddad@jbcc.harvard.edu"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "jbcc.harvard.edu"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "medford.k12.ma.us"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "angela@thedantonios.net"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        query: "list:family.thedantonios.net"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "clare.vann.esq@gmail.com"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "dearbornstep.org"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "support@usms.org"
      },
      actions: {
        labels: [
          "Swimming"
        ]
      }
    },
    {
      filter: {
        from: "info@totalimmersion.net"
      },
      actions: {
        labels: [
          "Swimming"
        ]
      }
    },
    {
      filter: {
        from: "orders@starbucks.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "uber.us@uber.com"
      },
      actions: {
        archive: true,
        markRead: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "mcinfo@ups.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "no_reply@email.apple.com"
      },
      actions: {
        archive: true,
        markSpam: false,
        markRead: true,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "angelajvitulli@gmail.com OR avitulli@indecon.com",
        isEscaped: true
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "\"angela vitulli\"",
        isEscaped: true
      },
      actions: {
        markImportant: true,
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "PatientGateway@partners.org"
      },
      actions: {
        labels: [
          "Wellness"
        ]
      }
    },
    {
      filter: {
        from: "USPSInformeddelivery@informeddelivery.usps.com"
      },
      actions: {
        markImportant: false,
        category: "updates",
        labels: [
          "Mail"
        ]
      }
    },
    {
      filter: {
        from: "noreply@skeptoid.com"
      },
      actions: {
        labels: [
          "Skeptoid"
        ]
      }
    },
    {
      filter: {
        from: "verizon-notification@verizon.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "donotreply@bcbsma.com"
      },
      actions: {
        labels: [
          "Wellness"
        ]
      }
    },
    {
      filter: {
        to: "family@thedantonios.net"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "payments-noreply@google.com"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "doctorisaiah@outlook.com"
      },
      actions: {
        labels: [
          "Family"
        ]
      }
    },
    {
      filter: {
        from: "alerts@parkmobileglobal.com"
      },
      actions: {
        archive: true,
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "stitchfix@email.stitchfix.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "NationalGridOnlineServices@nationalgrid.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "orders@eat.grubhub.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "venmo@venmo.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "orders-no-reply@chownow.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "donotreply@notifications.t-mobile.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "bates.edu"
      },
      actions: {
        labels: [
          "Bates"
        ]
      }
    },
    {
      filter: {
        from: "cmsmailer@civicplus.com"
      },
      actions: {
        labels: [
          "Melrose"
        ]
      }
    },
    {
      filter: {
        from: "DoNotReplyUS@welcome.aexp.com"
      },
      actions: {
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "noreply@resy.com"
      },
      actions: {
        labels: [
          "Dining"
        ]
      }
    },
    {
      filter: {
        from: "no-reply@opentable.com"
      },
      actions: {
        labels: [
          "Dining"
        ]
      }
    },
    {
      filter: {
        from: "noreply@zenoti.com"
      },
      actions: {
        labels: [
          "Self"
        ]
      }
    },
    {
      filter: {
        from: "admin_at_vagaro_com_ntpdcmkj55_03a64094@privaterelay.appleid.com"
      },
      actions: {
        labels: [
          "Self"
        ]
      }
    },
    {
      filter: {
        from: "envirosports.com"
      },
      actions: {
        labels: [
          "Swimming"
        ]
      }
    },
    {
      filter: {
        from: "shipping_notification@orders.apple.com"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "here4help@threads4thought.com"
      },
      actions: {
        archive: true,
        markSpam: false,
        markRead: true,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "here4help@threads4thought.com"
      },
      actions: {
        archive: true,
        markSpam: false,
        markRead: true,
        labels: [
          "Paper Trail"
        ]
      }
    },
    {
      filter: {
        from: "here4help@threads4thought.com"
      },
      actions: {
        markSpam: false,
        labels: [
          "Swimming"
        ]
      }
     },
     {
      filter: {
        from: "noreply@justride.com"
      },
      actions: {
        markSpam: false,
        labels: [
          "Swimming"
        ]
      }
     },
     {
      filter: {
        from: "your_order_US@orders.apple.com"
      },
      actions: {
        markSpam: false,
        labels: [
          "Paper Trail"
        ]
      }
     },
      {
      filter: {
        from: "receipts@messaging.squareup.com"
      },
      actions: {
        archive: true,
        markRead: true,
        labels: [
          "Paper Trail"
        ]
      }
    }
  ]
}
