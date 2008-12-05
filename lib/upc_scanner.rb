# (c)2008 Patrick Morgan and Master Web Design www.masterwebdesign.net  under Apache License 2.0
module UpcScanner
  
  class UpcImageScanner
    # Class that will read barcodes from images
    # Requires rjb gem and jar files lib/zxing-javase.jar and lib/zxing.jar

    ## Example Usage:
    # u = UpcImageScanner.new
    # code = u.read('test/02.jpg')
    # puts code
    require 'rubygems'
    require 'rjb'
    
    Rjb::load("#{File.dirname(__FILE__)}/zxing-javase.jar:#{File.dirname(__FILE__)}/zxing.jar", ['-Djava.awt.headless=true'])

    def initialize
      init_java_classes
    end

    # Read barcode from image file.  Provide filename
    def read(filename)
      read_file(filename)
      return code
    end
  
    private
    
    def init_java_classes
      @j_bufferedimage = Rjb::import('java.awt.image.BufferedImage')
      @j_imageio = Rjb::import('javax.imageio.ImageIO')
      @j_file = Rjb::import('java.io.File')
      @z_bufferedimagesource = Rjb::import('com.google.zxing.client.j2se.BufferedImageMonochromeBitmapSource')
      @z_source = Rjb::import('com.google.zxing.MonochromeBitmapSource')
      @z_reader = Rjb::import('com.google.zxing.MultiFormatReader')
      @z_result = Rjb::import('com.google.zxing.Result')
    end
  
    # Read file from filename
    def read_file(filename)
      raise "File not found: #{filename}" unless File.exist?(filename)
      file = @j_file.new(filename)
      @image = @j_imageio.read(file)
    end
  
    # Return code for image scanned from filename
    def code
      return get_upc(@image)
    end
  
    # use java libraries to read image
    def get_upc(image)
      source = @z_bufferedimagesource.new(image)
      reader = @z_reader.new
      result = reader.decode(source)
      return result.getText
    end
  
  end
  
  class UpcLookup
    require 'xmlrpc/client'
    SERVER = 'http://www.upcdatabase.com/rpc'
    
    def self.find(code)
      return find_online(code)
    end
    
    private
    
    def self.find_online(code)
      server = XMLRPC::Client.new2(SERVER)
      result = server.call("lookupUPC", code)
      return result
    end
    
  end

  class Scanner
    def self.read(filename)
      scanner = UpcImageScanner.new
      code = scanner.read(filename)
      return UpcLookup.find(code)
    end
  end

end