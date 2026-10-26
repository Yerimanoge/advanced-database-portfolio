// Akira Portfolio 4 | Run in mongosh or MongoDB Compass Playground.
use('akira_nosql');
db.wallet_activity.drop();

db.wallet_activity.insertMany([
  {
    walletId: 101, userId: 1, walletType: 'personal', currency: 'AKR', currentBalance: NumberDecimal('948.558797'),
    recentEvents: [
      { transactionId: 1001, occurredAt: ISODate('2026-09-01T08:00:00Z'), direction: 'out', type: 'transfer', status: 'completed', amount: NumberDecimal('10.000000'), counterpartyWalletId: 120 },
      { transactionId: 1002, occurredAt: ISODate('2026-09-03T09:00:00Z'), direction: 'out', type: 'payment', status: 'completed', amount: NumberDecimal('8.500000'), merchant: { merchantId: 1, name: 'Nova Grocers', category: 'Groceries' } }
    ],
    projectionUpdatedAt: ISODate('2026-10-23T10:00:00Z')
  },
  {
    walletId: 120, userId: 20, walletType: 'personal', currency: 'AKR', currentBalance: NumberDecimal('210.000000'),
    recentEvents: [
      { transactionId: 1001, occurredAt: ISODate('2026-09-01T08:00:00Z'), direction: 'in', type: 'transfer', status: 'completed', amount: NumberDecimal('10.000000'), counterpartyWalletId: 101 }
    ],
    projectionUpdatedAt: ISODate('2026-10-23T10:00:00Z')
  }
]);

db.wallet_activity.createIndex({ walletId: 1 }, { unique: true, name: 'uq_wallet_activity_wallet' });
db.wallet_activity.createIndex({ 'recentEvents.occurredAt': -1 }, { name: 'idx_recent_event_time' });
db.wallet_activity.createIndex({ 'recentEvents.merchant.category': 1, 'recentEvents.status': 1 }, { name: 'idx_merchant_category_status' });
