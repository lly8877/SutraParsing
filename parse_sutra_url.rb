require 'nokogiri'
require 'open-uri'

def parse_sutra_url url
  content = book_string = title_string = author_string = ''
  
  html = open(url ).read
  html.force_encoding("gbk")
  html.encode!("utf-8", :undef => :replace, :replace => "", :invalid => :replace)
  doc = Nokogiri::HTML.parse html
  content << '''
  <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
  "http://www.w3.org/TR/html4/loose.dtd">
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body>
  '''

  the_content_tr = nil
  
  doc.traverse do |node|
    is_jw = node.name == 'p' && node['class'] == 'jw'
    is_jwbt =  node.name == 'p' && node['class'] == 'jwbt'
    is_div = node.name == 'div' && node['class'] == 'jwbtbm'
    if is_jwbt
      content << "<h1>#{node.text}</h1>"
    elsif is_jw
      content << node
      if the_content_tr.nil?
        the_content_tr = find_tr_parent(node)
      end
    elsif is_div
      content << "<h2>#{node.text}</h2>"
    end
      # puts node if node.name == 'div' and node.attribute("class") == "jwbtbm"
  end

  content <<  "</body></html>"
  
  

  meta_data = parse_book_meta_data(find_previous_tr(the_content_tr))
  {
    book_string: meta_data[0],
    title_string: meta_data[1],
    author_string: meta_data[2],
    content: content
  }
end

def find_tr_parent node
  if node.parent.nil?
    return nil
  elsif node.parent.name == "tr"
    return node.parent
  else
    return find_tr_parent(node.parent)
  end
end

def find_previous_tr node
  if node.previous.nil?
    return nil
  elsif node.previous.name == "tr"
    return node.previous
  else
    return find_previous_tr(node.previous)
  end
end

def parse_book_meta_data node
  array = []
  node.css('p').each do |p|
    array << p.text.gsub(/[[:space:]]/, '')
  end
  array
end

  # parse_sutra_url 'http://www.goodweb.cn/sutra/dazangjing/0000.asp'
  