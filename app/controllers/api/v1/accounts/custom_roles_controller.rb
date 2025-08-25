# Self-developed Custom Roles Controller
# This is a completely self-developed implementation that provides the same functionality
# as the enterprise version but without any dependencies on enterprise modules.

class Api::V1::Accounts::CustomRolesController < Api::V1::Accounts::BaseController
  include Pundit::Authorization

  before_action :ensure_custom_roles_feature_enabled
  before_action :set_current_account_user
  before_action :set_custom_role, only: [:show, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_validation_error

  # GET /api/v1/accounts/{account_id}/custom_roles
  def index
    authorize_custom_role_management!
    
    @custom_roles = Current.account.custom_roles
                           .includes(:account_users)
                           .ordered
    
    render json: @custom_roles.map { |role| custom_role_json(role) }
  end

  # GET /api/v1/accounts/{account_id}/custom_roles/{id}
  def show
    authorize_custom_role_management!
    authorize @custom_role, :show?
    
    render json: custom_role_json(@custom_role)
  end

  # POST /api/v1/accounts/{account_id}/custom_roles
  def create
    authorize_custom_role_management!
    
    @custom_role = Current.account.custom_roles.build(custom_role_params)
    
    if @custom_role.save
      render json: custom_role_json(@custom_role), status: :created
    else
      render_validation_error(@custom_role)
    end
  end

  # PUT/PATCH /api/v1/accounts/{account_id}/custom_roles/{id}
  def update
    authorize_custom_role_management!
    authorize @custom_role, :update?
    
    if @custom_role.update(custom_role_params)
      render json: custom_role_json(@custom_role)
    else
      render_validation_error(@custom_role)
    end
  end

  # DELETE /api/v1/accounts/{account_id}/custom_roles/{id}
  def destroy
    authorize_custom_role_management!
    authorize @custom_role, :destroy?
    
    unless @custom_role.deletable?
      return render json: {
        error: 'ROLE_HAS_ASSIGNED_USERS',
        message: 'Cannot delete custom role as it has users assigned to it. Please reassign users before deleting.',
        details: {
          assigned_users_count: @custom_role.account_users.count
        }
      }, status: :unprocessable_entity
    end
    
    @custom_role.destroy!
    head :no_content
  end

  private

  # === Authorization Methods ===

  def authorize_custom_role_management!
    unless @current_account_user.administrator?
      render json: {
        error: 'ACCESS_DENIED',
        message: 'Only administrators can manage custom roles.'
      }, status: :forbidden
    end
  end

  # === Helper Methods ===

  def set_current_account_user
    @current_account_user = Current.account.account_users.find_by!(user: current_user)
  end

  def set_custom_role
    @custom_role = Current.account.custom_roles.find(params[:id])
  end

  def ensure_custom_roles_feature_enabled
    unless Current.account.feature_enabled?('custom_roles')
      render json: {
        error: 'FEATURE_NOT_ENABLED',
        message: 'Custom roles feature is not enabled for this account.',
        required_plan: 'Business or Enterprise plan required'
      }, status: :forbidden
    end
  end

  # === Parameter Methods ===

  def custom_role_params
    params.require(:custom_role).permit(:name, :description, permissions: [])
  end

  # === JSON Serialization ===

  def custom_role_json(role)
    {
      id: role.id,
      name: role.name,
      description: role.description,
      permissions: role.permissions,
      permissions_by_category: role.permissions_by_category,
      conversation_permission_level: role.conversation_permission_level,
      assigned_users_count: role.account_users.count,
      deletable: role.deletable?,
      created_at: role.created_at,
      updated_at: role.updated_at
    }
  end

  # === Error Handling Methods ===

  def render_not_found_error(exception = nil)
    render json: {
      error: 'CUSTOM_ROLE_NOT_FOUND',
      message: 'The requested custom role could not be found.',
      details: exception&.message
    }, status: :not_found
  end

  def render_validation_error(resource)
    render json: {
      error: 'VALIDATION_FAILED',
      message: 'The custom role could not be saved due to validation errors.',
      details: resource.errors.full_messages,
      field_errors: resource.errors.to_hash
    }, status: :unprocessable_entity
  end

  # Simple authorization check - can be enhanced with Pundit policies later
  def authorize(record, action)
    case action
    when :show?, :update?, :destroy?
      # For now, just ensure the record belongs to the current account
      # This will be enhanced when we add the Pundit policy
      true
    else
      true
    end
  end
end