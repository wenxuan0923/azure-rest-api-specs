import "@typespec/rest";
import "@typespec/http";
import "@typespec/versioning";
import "@azure-tools/typespec-azure-core";
import "@azure-tools/typespec-client-generator-core";
import "./models/common.models.tsp";
import "./models/pii.entity.recognition.tsp";
import "./models/summarization.tsp";

using Azure.ClientGenerator.Core;
using TypeSpec.Http;
using TypeSpec.Rest;
using TypeSpec.Versioning;
using Azure.Core;
using Azure.Core.Traits;

/** The language service API is a suite of natural language processing (NLP) skills built with best-in-class Microsoft machine learning algorithms.
 * The API can be used to analyze unstructured text for tasks such as sentiment analysis, key phrase extraction, language detection and question answering.
 * Further documentation can be found in <a href=\"https://learn.microsoft.com/azure/cognitive-services/language-service/overview\">https://learn.microsoft.com/azure/cognitive-services/language-service/overview</a>.0 */
@useAuth(
  ApiKeyAuth<ApiKeyLocation.header, "Ocp-Apim-Subscription-Key"> | OAuth2Auth<[
    {
      type: OAuth2FlowType.authorizationCode,
      authorizationUrl: "https://login.microsoftonline.com/common/oauth2/authorize",
      tokenUrl: "https://login.microsoftonline.com/common/oauth2/token",
      scopes: ["https://cognitiveservices.azure.com/.default"],
    }
  ]>
)
@service(#{ title: "Microsoft Cognitive Language Service - Document Analysis" })
@server(
  "{Endpoint}/language",
  "Single server endpoint",
  {
    /** Supported Cognitive Services endpoint (e.g., https://<resource-name>.api.cognitiveservices.azure.com). */
    Endpoint: string,
  }
)
@versioned(Versions)
namespace Language.AnalyzeDocuments;

/** Analyze Documents Service Versions */
enum Versions {
  /** Version 2024-11-15-preview */
  @useDependency(Azure.Core.Versions.v1_0_Preview_2)
  v2024_11_15_preview: "2024-11-15-preview",
}

alias ServiceTraits = NoRepeatableRequests &
  NoConditionalRequests &
  NoClientRequestId;

alias languageOperations = ResourceOperations<ServiceTraits, ErrorResponse>;

/** Get the status of a document analysis job. A job can consist of one or more tasks. After all tasks succeed, the job transitions to the succeeded state and results are available for each task. */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations"
#suppress "@azure-tools/typespec-azure-core/use-standard-names" "Existing name"
@summary("Get analysis status and results")
op analyzeDocumentsJobStatus is languageOperations.ResourceRead<
  AnalyzeDocumentsJobState,
  AnalyzeDocumentsJobQueryParameters
>;

/** Submit a collection of text documents for analysis. Specify one or more unique tasks to be executed as a long-running operation. */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations"
@route("/analyze-documents/jobs")
@pollingOperation(analyzeDocumentsJobStatus)
op analyzeDocumentsSubmitJob is Foundations.LongRunningOperation<
  {
    /** The input for the analyze documents operation. */
    @bodyRoot
    @clientName("AnalyzeDocumentOperationInput", "csharp")
    body: AnalyzeDocumentJobsInput;
  },
  AcceptedResponse,
  {},
  ErrorResponse
>;

/** Cancel a long-running Text Analysis job. */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations"
@summary("Cancel a long-running Text Analysis job.")
@pollingOperation(analyzeDocumentsJobStatus)
@route("/analyze-documents/jobs/{jobId}:cancel")
@post
op analyzeDocumentsCancelJob is Foundations.LongRunningOperation<
  {
    /** The job ID to cancel. */
    @path
    jobId: uuid;
  },
  AcceptedResponse,
  {},
  ErrorResponse
>;
