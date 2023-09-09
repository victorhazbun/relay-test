# README

# 1 - Improve API Response Time

**Root Cause:** Full SQL table scan.

**Solution:** Consider using Redis as a primary data store for hit counts, as it's well-suited for high-performance data retrieval.

# 2 - "Over Quota" Errors for Australian Users

**Root Cause:** The issue is related to time zone differences when calculating the beginning of the month.

**Solution:** Use the current user time zone for quota calculations.

# 3 - Users Making Requests Over the Monthly Limit

**Root Cause:** The issue likely arises due to a lack of synchronization and concurrency control when updating the hit count.
**Solution:** Utilize Redis as it's well-suited for this purpose and offers better performance and concurrency handling compared to traditional relational databases, which can be prone to locking issues and degraded performance in high-traffic scenarios.

# 4 - Improve Code Quality

**Issue:** The codebase has accumulated technical debt and bad coding practices.

**Solution:** Added automated tests, introduced service object for quota calculation, introduced app config service to read application configs.
