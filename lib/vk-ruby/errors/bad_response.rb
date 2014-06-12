class VK::BadResponse < VK::Error
  def_delegators :@env, :status

  def to_s
    "status=#{ status }"
  end
end