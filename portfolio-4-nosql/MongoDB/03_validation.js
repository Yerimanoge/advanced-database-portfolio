use('akira_nosql');
db.wallet_activity.countDocuments();
db.wallet_activity.aggregate([
  { $project: { walletId: 1, missingEventFields: { $filter: { input: '$recentEvents', as: 'e', cond: { $or: [ { $eq: ['$$e.transactionId', null] }, { $eq: ['$$e.amount', null] }, { $eq: ['$$e.status', null] } ] } } } } },
  { $match: { 'missingEventFields.0': { $exists: true } } }
]);
db.wallet_activity.getIndexes();
