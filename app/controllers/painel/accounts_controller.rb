module Painel
  class AccountsController < BaseController
    def show
      @user = current_user
    end

    def update
      @user = current_user

      if changing_password?
        if params.dig(:user, :password).blank?
          @user.errors.add(:password, "não pode ficar em branco")
          render :show, status: :unprocessable_entity and return
        end

        unless @user.authenticate(params[:user][:current_password])
          @user.errors.add(:current_password, "está incorreta")
          render :show, status: :unprocessable_entity and return
        end
      end

      if @user.update(account_params)
        redirect_to painel_account_path, notice: "Informações da conta atualizadas com sucesso!"
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def changing_password?
      params.dig(:user, :password).present? ||
        params.dig(:user, :password_confirmation).present? ||
        params.dig(:user, :current_password).present?
    end

    def account_params
      if changing_password?
        params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
      else
        params.require(:user).permit(:name, :email_address)
      end
    end
  end
end
