#!/usr/bin/env ruby

require 'tempfile'
require 'optparse'

class Flac2AAC
  attr_reader :options

  def initialize(arguments)
    @arguments = arguments
    @metadata = {}
    @options = {}
  end
  
  def run 
    if parsed_options?
      parse_arguments
      convert_tracks
    end
  end
  
  protected 
  
  def convert_tracks
    @tracks.each_with_index do |track, track_number|
      convert_track(track, track_number + 1)
    end
  end
  
  def convert_track (trackname, track_number)

    basename = File.basename(trackname, File.extname(trackname))
  
    begin
      puts "Transcoding #{trackname} to #{basename}.m4a...\n"
      aiff = Tempfile.new(basename)
      aiffname = "#{aiff.path}.aiff"
      aiff.close
      system %Q[flac -sdc "#{trackname}" --force-aiff-format #{'-F' if @options[:decode_errors]} -o "#{aiffname}"]
      system %Q[afconvert "#{aiffname}" -q 127 -b 128000 -f m4af -d aac -o "#{basename}.m4a"]
      
      metadata_args = prepare_metadata_args(trackname)
      if (@options[:number_tracks]) then 
        metadata_args = "#{metadata_args} --tracknum #{track_number}/#{@tracks.length}"
      end
      system %Q[AtomicParsley "#{basename}.m4a" #{metadata_args} --overWrite]
    ensure
      aiff.unlink
    end

  end
  
  def prepare_metadata_args (trackname)
    argument_map = {
        :date => "--year",        
      }
    metadata_args = ""
    @metadata.each do |key, value| 
      metadata_args = %Q[#{metadata_args} --#{argument_map.has_key?(key) ? argument_map[key] : key.intern} "#{value}"]
      if key == :artist and @options[:setAlbumArtist] then
        metadata_args = %Q[#{metadata_args} --albumArtist "#{value}"]
      end
    end
    
    return metadata_args
  end
  
  def extract_metadata (trackname)
    
    args = ""
    
    `metaflac --export-tags-to=- "#{trackname}"`.each_line do |line|
      key, value = line.strip.split('=', 2)
      key = key.downcase.intern
      if (@metadata[:override]) then
        @metadata[key] = value unless @metadata[key].has_key?(key)
      else 
        @metadata[key] = value
      end
    end
  end
  
  def parsed_options?
    # Specify options
    opts = OptionParser.new 
    
    opts.separator ""
    opts.separator "Specific options:"

    opts.on_tail("-h", "--help", "Show this message") do
      usage opts
      exit
    end
    
    opts.on("-aARTIST", "-a ARTIST", "--artist=ARTIST", "Artist to set on track[s]", String) do |artist| 
      @metadata[:artist] = artist
    end
    
    opts.on("--album-artist=ARTIST", "Album artist to set on track[s]", String) do |artist| 
      @metadata[:albumArtist] = artist
    end
          
    opts.on("-AALBUM", "-A ALBUM", "--album=ALBUM", "Album name to set on track[s]", String) do |album| 
      @metadata[:album] = album
    end
    
    opts.on("-yYEAR", "-y YEAR", "--year=YEAR", "Year to set on track[s]", String) do |year| 
      @metadata[:year] = year
    end
    
    opts.on("-tTITLE", "-t TITLE", "--title=TITLE", "Title to set on track[s]", String) do |title| 
      @metadata[:title] = title
    end
    
    opts.on("-TTRACK", "-T TRACK", "--track=TRACK", "Track number to set on track[s]", String) do |track| 
      @metadata[:tracknum] = track
    end
    
    opts.on("-dDISK", "-d DISK", "--disk=DISK", "Disk number to set on tracks", String) do |disk| 
      @metadata[:disk] = disk
    end
    
    opts.on("-cCOVER", "-c COVER", "--cover=COVER", "Cover art to set on tracks",String) do |cover| 
      @metadata[:artwork] = cover
    end
    
    opts.on("-n", "--[no-]number-tracks", "Number tracks in the order they appear on the commandline") do |number|
      @options[:number_tracks] = number
    end
    
    opts.on("-o", "--[no-]override", "Override metadata provided in the FLAC file") do |override|
      @options[:override] = override
    end
    
    opts.on("-F", "--[no-]decode-through-errors", "Continue decoding if FLAC encounters a bitstream error.") do |number|
      @options[:decode_errors] = number
    end
    
    opts.on("--[no-]set-album-artist", "Set album artist to the same as artist") do |setAlbumArtist| 
      @options[:setAlbumArtist] = setAlbumArtist
    end
    
    opts.parse!(@arguments) # rescue return false
    return true
  end
  
  def parse_arguments
    @tracks = @arguments
    return true    
  end
  
  def usage(options)
    print options
    print "\n"
    print "If multiple files are provided, the metadata will be set on all output files."
  end
    
end

app = Flac2AAC.new(ARGV)
app.run
