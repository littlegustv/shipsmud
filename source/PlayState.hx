package;

import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.addons.ui.FlxInputText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class PlayState extends FlxState
{
	var client:mphx.client.Client;
	var hosting:Bool = false;
	var registered:Bool = false;

	var content_buffer:String = "";
	var content:FlxText;
	var input:FlxInputText;

	var markup_rules:Array<FlxTextFormatMarkerPair>;

	var name:String;

	public function new( client:mphx.client.Client, hosting:Bool = false, name:String ) {
		super();
		this.client = client;
		this.name = name;
		this.hosting = hosting;
	}

	override public function create():Void
	{
		super.create();

		FlxG.autoPause = false;
		FlxG.mouse.enabled = false;

		var format1 = new FlxTextFormat(0xE6E600, false, false, null);
		var format2 = new FlxTextFormat(0xFF0000, false, false, null);
		var format3 = new FlxTextFormat(0x9999FF, false, false, null);
		var format4 = new FlxTextFormat(0xFFFFFF, true, false, null);

		markup_rules = [
			new FlxTextFormatMarkerPair(format1, "<y>"),
			new FlxTextFormatMarkerPair(format2, "<r>"),
			new FlxTextFormatMarkerPair(format3, "<b>"),
			new FlxTextFormatMarkerPair(format4, "<strong>"),
		];

		// background texture

		for ( i in 0...Math.ceil( FlxG.width / 531 ) ) {
			for ( j in 0...Math.ceil( FlxG.height / 337 ) ) {
				add( new FlxSprite( i * 531, j * 337, AssetPaths.zwartevilt__png ) );
			}
		}

		content = new FlxText( 10, 10, FlxG.width - 20, "Connected.", 12 );
		add( content );

		input = new FlxInputText(10, FlxG.height - 32, FlxG.width - 20, "", 12, FlxColor.WHITE, FlxColor.TRANSPARENT );
		input.caretColor = FlxColor.WHITE;
		input.hasFocus = true;
		add( input );

		client.send( "RegisterNewClient", { name: name } );

		client.events.on( "RegisterSuccessful", function ( data ) {
			if ( data.name != this.name ) {
				this.output( "<r>'" + this.name + "' was already in use.  Name changed to '" + data.name + "'<r>" );
				this.name = data.name;
			}
			this.registered = true;
		});

 		client.events.on( "Input" , function ( data ) {
 			this.output( "<y>[" + data.name + "]<y> " + data.msg ); 			
		});

 		client.events.on( "Data" , function ( data ) {
 			this.output( data.msg );
		});
	}

	function output ( text:String ) {
		content_buffer += text + "\n";
		content.applyMarkup( content_buffer, markup_rules );
		if ( content.height > FlxG.height - 56 ) {
			content.y = ( FlxG.height - 46 ) - content.height;
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		client.update();

		if ( FlxG.keys.justPressed.ENTER ) {
			if ( registered ) {
				client.send( "Input", { name: name, msg: input.text } );
				input.text = "";
				input.caretIndex = 0;
			}
		}
	}
}
