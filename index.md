# Distributed Methods

## Summary
"Distributed Methods" refers to data operations that can be implemented using map-reduce architecture with each node in the network performing data operations independently, orchestrated by a central system that manages intermediate and final results ("aggregator", or "mapper" or "oracle"). Methods include Analysis Methods (e.g. regression, SVM), Record Linkage Methods (a.k.a EMPI), Data Transformation, and Data Profiling Methods. 

Development often requires adaptation of existing APIs or services to distributed architecture (e.g. OHDSI WebAPI, R and/or SAS code for fitting generalized linear models). 

In order for method to be implemented successfully in a distributed framework, methods need to separate components of computation that will occur in different parts of the architecture. 

Current approach is that method should must be broken down into 4 component resources - all of the Distribted Methods should assume this model.

1. Server side query parameterization & UI (right now integrated with PMN portal)
2. Client-side (need to be executed by each site),
3. "aggregator" (if anything needs to be computed for all sites participating in a distributed query - can be simple pass-through)
4. Server-side result display (right now not tightly integrated with PMN portal, so could route to a Shiny server, for example)

Technically, any distributed method must specify 
* What data input formats are expected for components 1-4
* What data output formats are expected for components 1-4
* Requirements and platforms/semantics/models for each step.

These convnetions need to be specified clearly as we work through the different use-cases. More detail below...

## Creating Subnetworks devoted to specific operations and projects. 
The pSCANNER-PMN system enables users to create sub-groups of users and resources that can collaborate on a range of data operations (methods) in an ongoing way. For example, a subnetwork containing only UC System might approve cohort discovery methods. All of the PRIME participants in pSCANNER might approve mutual sharing of quality measurement. 

### Specifying Workflows for Networked Data Operations (Protocols)
There are typically several steps in creating an end product that can be published, including steps required for implementing a common data model for cohort discovery purposes. A workflow specificaiton will be a resource in its own right, the SCANNER and pSCANNER-PMN systems include user interfaces for specifying these workflows, including approval steps. 
### pSCANNER Protocol Specification and Approval Process
The project approval workflow involves obtaining approval from each entity participating in a networked protocol. This includes speificaiton of what data resources are required (e.g. OMOP CDM; bariatric surgery dataset) and what sequence of operations (e.g. dataset extraction; logistic regression) are required. This step also allows specification of what the privacy level is of input and output data for each step, including outputs that are transferred centrally. (SOMEDAY: Ideally these would be directly linked with local and/or central IRBs and ultimately patient-level approvals).
* Operations that change privacy levels 
* Operations that create new resources for future use (e.g. creating a DB view or data set)

### Differences from SCANNER and SHRINE in Unattended vs. Attended Operations
The original --SCANNER-- protocol specification includes specificaiton of asynchronous and synchronous operations for each step in the protocol (PMN "attended" and "unattended" operations). The PopMedNet framework, as currently implemented, requires that each site must create a separate data mart resource for data operated upon in "unattended" and "attended" mechanisms. The SHRINE approach for networking i2b2 data marts instantiates all i2b2 databases as "unattended". 

The UX on this for the pSCANNER-PMN Portal needs to be worked out.   
 
## More on Protocol Specificaitons Piped Data Operations and Workflows (i.e. Prospective "Provenance")

1. Data Input(s)
2. Data Operations and Parmeters
3. Data Output(s)

TODO: Create a list of required metadata elements for each resource indexed in pSCANNER Distributed Methods. 
+ Data -Definitions- Could be single datasets using metadata standards or reference models with known specifications.
+ Data -Operations- (input data dictionary or data type, output data dictionary or type, environment requirements)

TODO: Consider use of the FHIR Task model to pipe and chain data operations together to complete an analysis

## Platform Independent Specifications for Data and Operations
A desired feature of the pSCANNER Architecture is supporting a requirement for supporting heterogeneous data models and software enviornments. There are different ways of supporting this requirement.

### Specifying Operations
Natural language specificaitons as well as platform specific technical/executable programs are required. 
1. Maintain independent versions of programs with different stewards (e.g. PostGres version and Oracle version). This approach is the most likely to get out of sync across implementations, but also will be the one that is easiest to understand. This is what we do with all of our ETL from source systems to CDMs and between different CDMs.   
2. Code Generation from Platform Specific Impemenation - Maintain a reference file in one format, and use software that converts from one platform/dialect to another (e.g. LINQ, many different R-based analysis frameworks).  
3. Code Generation from Platform Independent Specificaiton - Maintain a platform-independent specifciation for operations and employ translation software to specific environemnts (e.g. converting XML or JSON specifications to SQL, converting PMML into R or SAS). 
* This approach is most attractive in cases where user interfaces exist for authoring programs (e.g. i2b2, Measure Authoring Tools, etc.
* It is also attractive for creating multi-step workflows where operations might involve transformations in one environment and analysis in anotehr, for example.

Both 2 and 3 lend themselves to implemenations as web services and the possiblity of "on the fly" code generation. In most cases, logical operations that are more complex than booleen logic or common database expressions will require creating or invoking stored procedures (e.g. using "logistic regression") In the case of healthcare-specific components, concepts like "length of stay" might be easier to implement programmatically as stored procedures in different RDBMS or statistical platforms). We need some kind of validation framework and system for maintainig stored procedures for each platform and keeping refactoring in sync. Each local resources will need to be validated before queries are run.

### Data Specifications
There are a number of ways in which informaiton models describing underlying data can be specified. We use these informaiton models to create the inputs to data operations. (TODO: Explain all of this better).

A FHIR Data Resource Profile, a Data Dictionary, Metadata, etc. are all ways that data can be exposed for analysis.

1. Variables (or table columns, fields, or in ML "features")
2. Value Sets (or "ontologies" - this is the simplest type of data operation). 
3. Derivation and processing rules in natural languge as well as implementation programs
4. Privacy level

## Authorizations and Access Control
User experinece for groups of users needs to be ironed out in PMN. The permissioning system is very flexible, but therfore also difficult to manage. It would be attractive to use InCommon for some of this.

## Summary
Conventions we use and structure of repositories should adhere to a shared understanding of these approaches. Ideally, we would have validation procedures to ensure conformance to metadata standards.
