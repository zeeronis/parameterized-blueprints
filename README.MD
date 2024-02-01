[Parameterized Blueprints](https://factorio.com/blog/post/fff-392)
=======
### A basic implementation of the parameterized blueprints shown in [FFF-392](https://factorio.com/blog/post/fff-392)

This mod adds 10 new items and recipes each named "Placeholder 0" through to "Placeholder 9"
Any references to these recipes or items (e.g. assembler set recipe, constant combinator outputs) can be replaced before placing a blueprint containing them.
The items are unobtainable and are only used to allow filters and such to be replaced.

## Usage
create or select a blueprint (copy area and blueprint tool both work) that contains the placeholder recipes or items
this blueprint must contain a placeholder recipe or signal
a window will show up on the left side of the screen with all the placeholders in that blueprint that can be replaced.
Due to limitations with the modding API, blueprints that are present in your inventory, and blueprints that came from the blueprint library have to be handled differently.
- If the blueprint originated from the library you can click on the empty slots to the right of the placeholders to select what item/fluid it will be replaced with.
- If the blueprint came from your inventory you must first press 'Q' to deselect it as clicking on one of the selection slots will select the blueprint. In this mode the window will stay open in its current state until either the close button is pressed or another blueprint is selected

If the item/fluid you have selected has multiple recipes that can craft it, a second selection slot will appear to the right allowing you to select the specific recipe to use. This can be left blank if you do not need to use it as a recipe
Leaving any item/fluid slots blank will mean that the placeholder will be removed and replaced with nothing

Once you have selected all the replacements you wish to perform, press the "Create Blueprint" button. This will push the modified blueprint into your paste history and select it.

## Known Issues
An adjusted blueprint that originated from the blueprint library will not have any tiles (API limitation) The original blueprint is not modified

I am not an artist and I know the icons don't look great. If someone is willing to contribute icons then feel free!