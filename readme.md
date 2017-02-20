# Distributed Methods 


## Summary
"Distributed Methods" refers to data operations that can be implemented using map-reduce architecture with each node in the network performing data operations independently, orchestrated by a central system that manages intermediate and final results ("aggregator", or "mapper" or "oracle"). Methods include Analysis Methods (e.g. regression, SVM), Record Linkage Methods (a.k.a EMPI), Data Transformation, and Data Profiling Methods. 

Development often requires adaptation of existing APIs or services to distributed architecture (e.g. OHDSI WebAPI, R and/or SAS code for fitting generalized linear models). 

In order for method to be implemented successfully in a distributed framework, methods need to separate components of computation that will occur in different parts of the architecture. 

Current approach is that methods that can be included in a pSCANNER Protocol and can be proposed to a subnetwork in a [PMN Scanner Study](https://github.com/pSCANNER/PopMedNet/tree/master/Portal/DNS_SCNR-Source/DNS_SCNR/Lpp.Scanner.Workflow.ScannerStudy) Request Type should must be broken down into 4 component resources - all of the Distribted Methods should assume this model.

1. Server side query parameterization & UI (right now integrated with PMN portal - [NewAnalysis.cs](https://github.com/pSCANNER/PopMedNet/tree/master/Portal/DNS_SCNR-Source/DNS_SCNR/Lpp.Scanner.Workflow.ScannerAnalysis/Activities))
2. Client-side - computatons that need to be executed by each site. In PMN framework, this is managed by The DMC. pSCANNER Adapters are [here](https://github.com/pSCANNER/PopMedNet/tree/master/DNC/Lpp.Adapters/Lpp.Scanner.DataMart.Model.Processors)
3. "Aggregator" code that specifies what, if anything, needs to be computed on combined resulst for all sites participating in a distributed query. This may be simple pass-through for display, concatenation, or one-time compuation, as well as more complex operations - [the Aggregating.cs](https://github.com/pSCANNER/PopMedNet/blob/master/Portal/DNS_SCNR-Source/DNS_SCNR/Lpp.Scanner.Workflow.ScannerAnalysis/Activities/Aggregating.cs) PMN code handles the queueing and DMC result collection currently.
4. Server-side result display (right now not tightly integrated with PMN portal, so could route to a Shiny server, for example)

Technically, any distributed method must specify 
* What data input formats are expected for components 1-4
* What data output formats are expected for components 1-4
* Requirements and platforms/semantics/models for each step.

Note that the PFA model calls \#3 a "Folding Engine" and splits it into "Tally" actions and "Merging". Currently PMN-pSCANNER approach does not initiate Merging until all parallelized outputs have been obtained by the PMN-pSCANNER Aggregating.cs function and subsequently released to the DMC responsible for "Merging" operations.  

## Conventions and Decomponsition of Methods
These convnetions need to be specified clearly as we work through the different use-cases. More detail below...

Methods follow basic input->{action}->output model. Inputs and outputs are typically datasets (or arrays), actions are typically computations that may be user defined functions or functions built into existing computing platforms. In distributed methods, actions are distributed over the network. In many cases a high level action is parallelized and decomponsed into computations. Most distributed methods have two roles corresponding to different categories of actions. One role is related to handling consolidation of parallelized outputs ("aggregator") and the other implements operations on locally managed data ("client")

In order to facilitate platform independence for analysis methods, we are trying to observe the syntax and specification formats developed for PMML: http://dmg.org. A network of heterogeneous PMML or PFA _consumers_ (e.g. SPSS, R, SAS, KNIME) can collaborate to estimate any generalized linear model (or any model with a convex error function) using gradient decent or Newton-Raphson methods orchestrated by an "aggregator". So only the aggregator node needs to have the user-defined functions for iteratively updating the coefficients until the error converges. We might consider some of the conventions and requirements in PFA. In particular, "aggregator" functions have been modeled in a way that PFA calls a `Folding Engine` that allows us to clearly articulate that PFA `tally` activities are handled by PMN whereas `merge` activities operate on collections.
http://dmg.org/pfa/docs/document_structure/ 

While PMML model includes transformations, Data Transformations and processing steps are not as well represented in PMML expressions and we may opt to extend them with expressions/UDFs from another standard (e.g. HQMF/CQF).

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

### Code Generation as a Service (CGaaS?) vs. Stored Procedures/Packages
We could use PFA and/or PMML as inputs to a central service for code generation, or we could contribute/extend packages or stored procedures to existing systems. (E.g. RPMML package on CRAN)

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

## Use Cases
These are some use cases and how each node in the computation operates. Note that the Portal is simply used for rendering HTML, queueing, and routing. Note that the OHDSI API may be very slow and require that sites run in "unattended" mode because the API makes multiple calls to the OMOP database, but some visualization methods will be able to run on a single de-identified extract. 

|Use Case|Locus|Role/Component|Computation|
|---|---|---|---|
|Horizontally Partitioned Regression|Portal|Protocol Specification|Render html for analysis parameters (sites, data variables & model specificaitons/parameters)|
|Horizontally Partitioned Regression|Data Site DMC|Model Scoring|Fits each iteration of model to local data, returns error and var-cov matrix|
|Horizontally Partitioned Regression|Aggregator/HB DMC|Model Parameter Estimation/Iteration|Retrieves error from each locally scored model, computes new coefficients/parameters on each iteration using IRLS algorithm, on convergence sends results for display.|
|Horizontally Partitioned Regression|Portal|Invoke Result Display Service|Obtains Final Message with model, displays results|
|Privacy Preserving Record Linkage|Data Site|Preparation|Offline/In advance create encrypted dataset wtih shared key, register to DMC, and (maybe compression too?)|
|Privacy Preserving Record Linkage|Portal|Protocol Specification|Render html for linkage parameters (identification of pre-encrypted data set, threshold?, subnetwork)|
|Privacy Preserving Record Linkage|Data Site DMC|Retrieval|Retrieve specified data set and send records to portal for queueing (maybe compression too?)|
|Privacy Preserving Record Linkage|Portal|Queueing|Wait for all sites to respond, route to aggregator node|
|Privacy Preserving Record Linkage|Aggregator DMC|Matching|(decompress), Run PPRL, assign identifier, probability, return result data set to portal with local and global IDs and metadata for routing|
|Privacy Preserving Record Linkage|Portal|Routing|Route identifiers to correct sites (this may require updates to current PMN portal code [here](https://github.com/pSCANNER/PopMedNet/blob/master/DNC/Lpp.Scanner.Workflow.ScannerAnalysis/DmcScannerResponseHandler.cs))|
|Privacy Preserving Record Linkage|Data Site DMC|Local Update|Update local data set with network wide identifiers, send "completed" response to portal|
|De-ID Data Visualization\*|Portal|Protocol Specification|Select data visualization method and parameters, subnetwork, parameters|
|De-ID Data Visualization|Data Site DMC|Extraction|Extract De-ID dataset and return to portal (compression?)|
|De-ID Data Visualization|Portal|Queuing|Wait for all sites to respond, send to aggregator node|
|De-ID Data Visualization|Aggregator/HB DMC|Merge and Prep|Merge Data Sets, prepare for display, return to portal for visualization|
|De-ID Data Visualization|Portal|Invokde Display Service|Render results (currently a link out)|
|OHDSI/Multi-Query\*|Portal|Protocol Specification|Render OHDSI GUI (or container), route each API call to Data Sites|
|OHDSI/Multi-Query|Data Site DMC|Local Computation|Invoke OHDSI API, retrieve results, return results|
|OHDSI/Multi-Query|Portal|Queueing|Wait for all sites to respond (or timeout?), send to aggregator|
|OHDSI/Multi-Query|Aggregator|Merge and Prep|Take list of results, combine into a single result in OHDSI format, route to portal|
|OHDSI/Multi-Query|Portal|Invoke Display Service|Route results to OHDSI GUI and display|



[Two use-cases for visualization/data exploration - one based on a de-identified data set where interactivity does not require multiple queries to source data, the other where intereactivity requires multple queries of source data (OHDSI)]
