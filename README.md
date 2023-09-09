# README

Things you may want to cover:

# 1 - Improve API Response Time

**Root Cause:** Full table scan.

**Solution:** DB index and DB sharding per country.

# 2 - "Over Quota" Errors for Australian Users

**Root Cause:** The issue is related to time zone differences when calculating the beginning of the month.

**Solution:** Use the current user time zone for quota calculations.

# 3 - Users Making Requests Over the Monthly Limit

**Root Cause:** ?
**Solution:** ?

# 4 - Improve Code Quality

**Issue:** The codebase has accumulated technical debt and bad coding practices.

**Solution:** Added automated tests, introduced service object for quota calculation, introduced app config service to read application configs.
