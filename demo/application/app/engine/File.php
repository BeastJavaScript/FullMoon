<?php

class File{
    protected $headers;
    protected $filename;
    protected $size;
    protected $mode="r";

    function __construct($filename,$size=null){
        $this->size=$size;
        $this->headers=[];
        $this->filename=$filename;
        $this->contentType();
    }

    function base(){
        $this->contentType();
    }

    function binary_mode(){
        $this->mode="rb";
    }

    function contentType($ctype="application/octet-stream"){
        $this->contentType=$ctype;
    }

    function size(){
        if($this->size === null){
            return filesize($this->filename);
        }
        else return $this->size;
    }

    function contentSize(){
        $this->headers["Content-Size"]=$this->size();
    }

    function status($s=200){
        $this->headers["Status"]=$s;
    }

    function send(){
        header("Content-Type: $this->contentType");

        // Check if it's a HTTP range request
        if(isset($_SERVER['HTTP_RANGE'])){
            echo $_SERVER['HTTP_RANGE'];
            // Parse the range header to get the byte offset
            $ranges = array_map(
                'intval', // Parse the parts into integer
                explode(
                    '-', // The range separator
                    substr($_SERVER['HTTP_RANGE'], 6) // Skip the `bytes=` part of the header
                )
            );

            // If the last range param is empty, it means the EOF (End of File)
            if(!$ranges[1]){
                $ranges[1] = $this->size() - 1;
            }

            // Send the appropriate headers
            header('HTTP/1.1 206 Partial Content');
            header('Accept-Ranges: bytes');
            header('Content-Length: ' . ($ranges[1] - $ranges[0])); // The size of the range

            // Send the ranges we offered
            header(
                sprintf(
                    'Content-Range: bytes %d-%d/%d', // The header format
                    $ranges[0], // The start range
                    $ranges[1], // The end range
                    $this->size() // Total size of the file
                )
            );

            // It's time to output the file
            $f = fopen($this->filename, $this->mode); // Open the file in binary mode
            $chunkSize = 8192; // The size of each chunk to output

            // Seek to the requested start range
            fseek($f, $ranges[0]);

            // Start outputting the data
            while(true){
                // Check if we have outputted all the data requested
                if(ftell($f) >= $ranges[1]){
                    break;
                }

                // Output the data
                echo fread($f, $chunkSize);

                // Flush the buffer immediately
                @ob_flush();
                flush();
            }
        }
        else {
            // It's not a range request, output the file anyway
            header('Content-Length: ' . $this->size());

            // Read the file
            @readfile($this->filename);
            // and flush the buffer
            @ob_flush();
            flush();
        }
    }
}