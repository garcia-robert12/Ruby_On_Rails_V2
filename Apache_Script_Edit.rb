class ApacheLogAnalyzer
  def initialize
    @total_hits_by_ip = Hash.new(0)
    @total_hits_per_url = Hash.new(0)
    @secret_hits_by_ip = Hash.new(0)
    @error_count = 0
  end
  def analyze(file_name)
    # Regex to match a single octet of an IPv4 address
    octet = /\d{,2}|1\d{2}|2[0-4]\d|25[0-5]/
    # Since an IPv4 address is made of four octets we will string them together
    # to match a full IPv4 address
    ip_regex = /^#{octet}\.#{octet}\.#{octet}\.#{octet}/
    # Regex to match an alphanumeric url ending with .html
    url_regex = /[a-zA-Z0-9]+.html/
    # TODO: Read in the file line by line using a loop
    # TODO: Match the various regex (IP Address, URL, Secret URL, and 404 Error)
    # and pass them to the count_hits function to be counted
    File.open(file_name).each do |line|
         ip = ip_regex.match(line).to_s
         url = url_regex.match(line).to_s
         secret = line.include?("secret")
         error = line.include?("404")
        count_hits(ip, url, secret, error)
  end
    print_hits
  end
  
    private
  def count_hits(ip, url, secret, error)
    @total_hits_by_ip[ip] += 1
    @total_hits_per_url[url] += 1
    @secret_hits_by_ip[ip] += 1 if secret
    @error_count += 1 if error
  end
  def print_hits
    print_string = 'IP: %s, Total Hits: %s, Secret Hits: %s'
    @total_hits_by_ip.sort.each do |ip, total_hits|
      secret_hits = @secret_hits_by_ip[ip]
      puts sprintf(print_string, ip, total_hits, secret_hits)
    end
    url_print_string = 'URL: %s, Number of Hits: %s'
    @total_hits_per_url.sort.each do |url, url_hits|
      puts sprintf(url_print_string, url, url_hits)
    end
    puts sprintf('Total Errors: %s', @error_count)
  end
 end
def usage
  puts "No log files passed, please pass at least one log file.\n\n"
  puts "USAGE: #{$PROGRAM_NAME} file1 [file2 ...]\n\n"
  puts "Analyzes apache2 log files for unique IP addresses and unique URLs."
end
def main
  if ARGV.empty?
    usage
    exit(1)
  end
  ARGV.each do |file_name|
    log_analyzer = ApacheLogAnalyzer.new
