-- Read-only Portfolio 5 evidence. 
SELECT @@hostname AS server_name, @@read_only AS read_only_mode, @@transaction_isolation AS isolation_level;
SELECT NOW() AS evidence_captured_at;
