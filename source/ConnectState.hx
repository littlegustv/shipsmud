package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUIButton;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.system.FlxAssets;

import mphx.utils.Log;

#if neko
	import neko.vm.Thread;
#elseif cpp
	import cpp.vm.Thread;
#end

// import Objects;

class ConnectState extends FlxState
{
  var client:mphx.client.Client;
  var connection_attempts:Int = 0;

  var PORT:Int = 8000;
  var HOST:String = "127.0.0.1";

  var hosting:Bool = false;

  var message:FlxText;

  /*
    Server code is only available on desktop platforms (probably?)
   */

  #if ( neko || cpp )
    var clients:Map<String, mphx.connection.IConnection> = new Map();
    var host:mphx.connection.IConnection;
    var server:mphx.server.impl.Server;

    function start_server() {
      server = new mphx.server.impl.Server( HOST, PORT );

      server.onConnectionAccepted = function ( reason:String, sender:mphx.connection.IConnection ) {
        trace("[ SERVER ] Connection Accepted: ", reason);
      };

      server.onConnectionClose =function ( reason:String, sender:mphx.connection.IConnection ) {
        trace("[ SERVER ] Connection Closed: ", reason);        
        for ( client in clients.keys() ) {
          if ( clients.get( client ) == sender ) {
            server.broadcast( "Leave", { client_id: client } );
            break;
          }
        }
      };

      server.events.on("RegisterNewClient", function( data:Dynamic, sender:mphx.connection.IConnection )
      {        
        // var id = makeID();
        var name:String = data.name;
        if ( clients.exists( name ) ) {
          var index = 0;
          while ( clients.exists( name + "_" + index ) ) {
            index += 1;
          }
          name = name + "_" + index;
        }
        clients.set( name, sender );
        if ( data.hosting == true ) {
          trace( "[ SERVER ] Registered new HOST: ", name );
          this.host = sender;
        } else {
          trace( "[ SERVER ] Registered new CLIENT: ", name );
        }        
        sender.send("RegisterSuccessful", { name: name });
      });

      server.events.on("Input", function ( data:Dynamic, sender:mphx.connection.IConnection ) {
        if ( data.msg == "who" ) {
          var formatted_list:String = "\n <strong>WHO<strong>\n";
          for ( key in clients.keys() ) {
            formatted_list += " <b>" + key + "<b>\n";
          }
          sender.send( "Data", { msg: formatted_list } );
        } else {
          server.broadcast( "Input", data );          
        }
      });

      server.start();
    }
  #end


  function connect ( name ) {
    message.text = "Connecting...";
		client = new mphx.client.Client( HOST, PORT );
    client.onConnectionError = function (error:Dynamic) {
      trace("[ CLIENT ] Connection Error:", error.keys, connection_attempts);
      connection_attempts += 1;
      if (connection_attempts <= 3) {
        client.connect();
      } else {
        message.text = "Failed to connect.";
      }
    };
    client.onConnectionClose = function (error:Dynamic) {
      trace("[ CLIENT ] Connection Closed", error);
    };
    client.onConnectionEstablished = function () {
    	trace("[ CLIENT ] Connection Established");
      message.text = "Connection successful.";
      FlxG.switchState( new PlayState( client, hosting, name ) );
    };
    client.connect();
  }

	override public function create():Void
	{
		super.create();

    FlxAssets.FONT_DEFAULT = AssetPaths.ubuntu__ttf;

    // background texture

    for ( i in 0...Math.ceil( FlxG.width / 531 ) ) {
      for ( j in 0...Math.ceil( FlxG.height / 337 ) ) {
        add( new FlxSprite( i * 531, j * 337, AssetPaths.zwartevilt__png ) );
      }
    }

    var title = new FlxText( 0, 16, FlxG.width, "Welcome to shipMUD" , 16 );
    title.alignment = FlxTextAlign.CENTER;
    add(title);

    var beta = new FlxText( FlxG.width / 3, 24, 128, "[ ALPHA ]", 8 );
    beta.setBorderStyle(OUTLINE, FlxColor.RED, 1);
    beta.angle = 30;
    beta.alignment = FlxTextAlign.CENTER;
    add( beta );

    message = new FlxText( 0, 144, FlxG.width );
    message.text = "";
    message.alignment = FlxTextAlign.CENTER;
    add( message );

		// Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info | DebugLevel.Networking;
		// Log.debugLevel = DebugLevel.Errors | DebugLevel.Warnings | DebugLevel.Info;

    var Y = FlxG.height / 4;

    var choose_name = new FlxUIInputText( FlxG.width / 2 - 160, Y, 320, "name", 24 );
    add( choose_name );

		var choose_host = new FlxUIInputText( FlxG.width / 2 - 160, Y + 32, 320, HOST, 24 );
		add(choose_host);

		var choose_port = new FlxUIInputText( FlxG.width / 2 - 160, Y + 64, 320, Std.string( PORT ), 24 );
		add(choose_port);

		var connect_button = new FlxUIButton( FlxG.width / 2 - 160, Y + 96, "CONNECT", function () {  
			HOST = choose_host.text;
			PORT = Std.parseInt( choose_port.text );
			connect( choose_name.text );
		});
    connect_button.setLabelFormat( AssetPaths.ubuntu__ttf, 24, FlxColor.WHITE );
		add(connect_button);

		#if ( neko || cpp )
			var host_button = new FlxUIButton( FlxG.width / 2 - 160, Y + 128, "HOST", function () {
				connect_button.kill();
				HOST = choose_host.text;
        this.hosting = true;
        Thread.create(this.start_server);
        connect( choose_name.text );
			});
      host_button.setLabelFormat( AssetPaths.ubuntu__ttf, 24, FlxColor.WHITE );
			add(host_button);
		#end
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

}