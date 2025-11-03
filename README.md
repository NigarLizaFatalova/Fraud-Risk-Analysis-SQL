# Fraud Risk Analysis — SQL Project

This project was developed to explore how SQL can be applied in a real banking environment to identify and prevent credit card fraud.

I worked with four core datasets — Customers (Müştərilər), Cards (Kartlar), Merchants (Satıcılar), and Transactions (Tranzaksiyalar) — and used SQL tools such as joins, window functions, aggregations, and CTEs. My main goal was not only to detect fraud patterns in the data, but also to understand what these patterns mean for business decisions inside a financial institution.



## Project Scope

I completed six analytical tasks that together create a full fraud-risk evaluation. Each one reflects how a bank’s fraud team might investigate suspicious behavior:

- Segmenting customers and card profiles to find higher-risk groups  
- Measuring inactivity before fraud to detect dormant card takeover  
- Analyzing sudden spikes in spending velocity  
- Investigating the behavior of stolen cards after the first fraud attack  
- Mapping merchants involved in multiple fraudulent transactions  
- Simulating an automated blocking rule to understand its impact on customers and fraud prevention  



## Results & Business Impact

The analysis showed that fraud follows behavioral patterns  is not random.

For example, new customers with higher credit limits experienced more fraud, which means some segments require more proactive monitoring. Dormant cards also stood out clearly: many fraud cases happened right after cards were inactive for a long time, showing the importance of early warnings.

I also discovered that fraudsters usually act quickly. Once a stolen card is successfully used, the next attack tends to occur soon after — meaning delayed alerts may allow multiple losses before detection.

When I simulated a proactive blocking rule for unusually large foreign transactions, the results demonstrated strong fraud-prevention potential  but they also showed how easily legitimate customers can be inconvenienced. This balance between **security** and **customer experience** is one of the biggest challenges in real banking operations. A bank must protect customers without damaging trust.

Finally, I found multiple merchants that were linked to fraud from different cards in short time windows. These locations are likely hotspots for organized fraud and should be prioritized for deeper investigation.

Overall, this project shows how SQL can convert transactional data into insights that enable a shift from **reacting after losses** to **preventing fraud before it happens**.


## Tools & Techniques

- Oracle SQL Developer  
- Window functions for time-based behavior analysis  
- CTEs (WITH clauses) for modular and readable logic  
- Business interpretation alongside technical work  


If you are reviewing this project and would like to discuss the analytical approach, the SQL design, or fraud detection strategies — I’d be happy to connect and talk more about the work behind it.
