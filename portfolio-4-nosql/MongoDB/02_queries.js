use('akira_nosql');

// Regular-user wallet statement: one document lookup, newest event first.
db.wallet_activity.aggregate([
  { $match: { walletId: 101 } },
  { $unwind: '$recentEvents' },
  { $sort: { 'recentEvents.occurredAt': -1 } },
  { $project: { _id: 0, walletId: 1, currentBalance: 1, event: '$recentEvents' } }
]);

// Merchant/analyst view: completed payment amount by category.
db.wallet_activity.aggregate([
  { $unwind: '$recentEvents' },
  { $match: { 'recentEvents.type': 'payment', 'recentEvents.status': 'completed' } },
  { $group: { _id: '$recentEvents.merchant.category', paymentCount: { $sum: 1 }, total: { $sum: '$recentEvents.amount' } } },
  { $sort: { total: -1 } }
]);

// Explain verifies the unique wallet lookup index.
db.wallet_activity.find({ walletId: 101 }).explain('executionStats');
