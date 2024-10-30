class EmailService
  include Singleton

  # @param[String] email
  # @return[String, NilClass]
  def to_domain(email:)
    return if email.blank?

    tmp = email.downcase.split('@')
    return if tmp.size <= 1

    tmp.last
  end

  # @param[String] domain
  # @param[String] email
  # @return[Boolean]
  def public_email_provider?(domain: nil, email: nil)
    result = false
    path   = Rails.root.join('db/datasets/all_email_provider_domains.txt')

    domain = to_domain(email:) if domain.blank?
    return false if domain.blank?

    File.readlines(path, chomp: true).each do |line|
      next unless line.downcase == domain.downcase

      result = true
      break
    end

    result
  end
end
