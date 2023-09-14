module HandlerFailureCollector
  class Helper
    def raise_all_warnings_as_errors(run_state)
      unless run_state['errors'].empty?
        raise_msg =  "\n" + ('!' * 70)
        raise_msg += "\n" + ('!' * 21) + ' THIS SYSTEM IS  NOT SECURE ' + ('!' * 21)
        raise_msg += "\n" + ('!' * 21) + ' BASELINE HARDENING FAILED !' + ('!' * 21)
        raise_msg += "\n" + ('!' * 28) + ' REVIEW LOGS !' + ('!' * 28)
        raise_msg += "\n" + ('!' * 70)
        run_state['errors'].each do |_profile, error|
          raise_msg += "\nError in:\n\t#{error}"
        end
        raise(raise_msg)
      end
    end
  end
end
