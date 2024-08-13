import "@azure-tools/typespec-azure-core";
import "@typespec/rest";
import "./models.tsp";

using TypeSpec.Rest;
using TypeSpec.Http;
using Azure.Core;

namespace KeyVault;

alias KeyVaultOperations = StandardResourceOperations;

alias PollingHeaders = Traits.ResponseHeadersTrait<{
  /**
   * The URI to poll for completion status.
   */
  @pollingLocation
  @header("Azure-AsyncOperation")
  azureAsyncOperation?: string;

  /**
   * The recommended number of seconds to wait before calling the URI specified in
   * Azure-AsyncOperation.
   */
  @header("Retry-After")
  retryAfter?: int32;
}>;

/**
 * Creates a full backup using a user-provided SAS token to an Azure blob storage
 * container.
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/backup")
@post
op fullBackup is Azure.Core.Foundations.Operation<
  SASTokenParameter,
  AcceptedResponse & FullBackupOperation,
  PollingHeaders
>;

/**
 * Pre-backup operation for checking whether the customer can perform a full
 * backup operation.
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/prebackup")
@post
op preFullBackup is Azure.Core.Foundations.Operation<
  PreBackupOperationParameters,
  {
    @statusCode _: 202;
    @body result: FullBackupOperation;
  },
  PollingHeaders
>;

/**
 * Returns the status of full backup operation
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/backup/{jobId}/pending")
@get
op fullBackupStatus is Azure.Core.Foundations.Operation<
  {
    /**
     * The id returned as part of the backup request
     */
    @path
    jobId: string;
  },
  FullBackupOperation
>;

/**
 * Pre-restore operation for checking whether the customer can perform a full
 * restore operation.
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/prerestore")
@put
op preFullRestoreOperation is Azure.Core.Foundations.Operation<
  PreRestoreOperationParameters,
  AcceptedResponse & RestoreOperation,
  PollingHeaders
>;

/**
 * Restores all key materials using the SAS token pointing to a previously stored
 * Azure Blob storage backup folder
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/restore")
@put
op fullRestoreOperation is Azure.Core.Foundations.Operation<
  RestoreOperationParameters,
  AcceptedResponse & RestoreOperation,
  PollingHeaders
>;

/**
 * Returns the status of restore operation
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/restore/{jobId}/pending")
@get
op restoreStatus is Azure.Core.Foundations.Operation<
  {
    /**
     * The Job Id returned part of the restore operation
     */
    @path
    jobId: string;
  },
  RestoreOperation
>;

/**
 * Restores all key versions of a given key using user supplied SAS token pointing
 * to a previously stored Azure Blob storage backup folder
 */
#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
@route("/keys/{keyName}/restore")
@put
op selectiveKeyRestoreOperation is Azure.Core.Foundations.Operation<
  {
    /**
     * The name of the key to be restored from the user supplied backup
     */
    @path
    keyName: string;

    /**
     * The Azure blob SAS token pointing to a folder where the previous successful
     * full backup was stored
     */
    @body
    restoreBlobDetails?: SelectiveKeyRestoreOperationParameters;
  },
  AcceptedResponse & SelectiveKeyRestoreOperation,
  PollingHeaders
>;

/**
 * Description of the pool setting to be updated
 */
@summary("""
  Updates key vault account setting, stores it, then returns the setting name and
  value to the client.
  """)
op updateSetting is KeyVaultOperations.ResourceUpdate<
  Setting,
  {
    /**
     * The parameters to update an account setting.
     */
    @body
    parameters: UpdateSettingRequest;
  }
>;

/**
 * Retrieves the setting object of a specified setting name.
 */
@summary("Get specified account setting object.")
op getSetting is KeyVaultOperations.ResourceRead<Setting>;

/**
 * Retrieves a list of all the available account settings that can be configured.
 */
@summary("List account settings.")
op getSettings is KeyVaultOperations.ResourceList<Setting>;

#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
interface RoleDefinitionsOperations {
  /**
   * Deletes a custom role definition.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionName}")
  @delete
  delete is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role definition to delete. Managed HSM only supports '/'.
       */
      @path
      scope: url;

      /**
       * The name (GUID) of the role definition to delete.
       */
      @path
      roleDefinitionName: string;
    },
    RoleDefinition
  >;

  /**
   * Creates or updates a custom role definition.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionName}")
  @put
  createOrUpdate is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role definition to create or update. Managed HSM only supports
       * '/'.
       */
      @path
      scope: url;

      /**
       * The name of the role definition to create or update. It can be any valid GUID.
       */
      @path
      roleDefinitionName: string;

      /**
       * Parameters for the role definition.
       */
      @body
      parameters: RoleDefinitionCreateParameters;
    },
    CreatedResponse & RoleDefinition
  >;

  /**
   * Get the specified role definition.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleDefinitions/{roleDefinitionName}")
  @get
  get is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role definition to get. Managed HSM only supports '/'.
       */
      @path
      scope: url;

      /**
       * The name of the role definition to get.
       */
      @path
      roleDefinitionName: string;
    },
    RoleDefinition
  >;

  /**
   * Get all role definitions that are applicable at scope and above.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleDefinitions")
  @get
  list is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role definition.
       */
      @path
      scope: url;

      /**
       * The filter to apply on the operation. Use atScopeAndBelow filter to search
       * below the given scope as well.
       */
      @query("$filter")
      $filter?: string;
    },
    RoleDefinitionListResult
  >;
}

#suppress "@azure-tools/typespec-azure-core/use-standard-operations" "Foundations.Operation is necessary for Key Vault"
interface RoleAssignmentsOperations {
  /**
   * Deletes a role assignment.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentName}")
  @delete
  delete is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role assignment to delete.
       */
      @path
      scope: url;

      /**
       * The name of the role assignment to delete.
       */
      @path
      roleAssignmentName: string;
    },
    RoleAssignment
  >;

  /**
   * Creates a role assignment.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentName}")
  @put
  create is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role assignment to create.
       */
      @path
      scope: url;

      /**
       * The name of the role assignment to create. It can be any valid GUID.
       */
      @path
      roleAssignmentName: string;

      /**
       * Parameters for the role assignment.
       */
      @body
      parameters: RoleAssignmentCreateParameters;
    },
    CreatedResponse & RoleAssignment
  >;

  /**
   * Get the specified role assignment.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleAssignments/{roleAssignmentName}")
  @get
  get is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role assignment.
       */
      @path
      scope: url;

      /**
       * The name of the role assignment to get.
       */
      @path
      roleAssignmentName: string;
    },
    RoleAssignment
  >;

  /**
   * Gets role assignments for a scope.
   */
  @route("/{scope}/providers/Microsoft.Authorization/roleAssignments")
  @get
  listForScope is Azure.Core.Foundations.Operation<
    {
      /**
       * The scope of the role assignments.
       */
      @path
      scope: url;

      /**
       * The filter to apply on the operation. Use $filter=atScope() to return all role
       * assignments at or above the scope. Use $filter=principalId eq {id} to return
       * all role assignments at, above or below the scope for the specified principal.
       */
      @query("$filter")
      $filter?: string;
    },
    RoleAssignmentListResult
  >;
}
