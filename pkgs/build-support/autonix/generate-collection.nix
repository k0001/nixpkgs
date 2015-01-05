{ stdenv, autonix, newScope }:

with stdenv.lib;
with autonix;

let
  breakRecursion = mapAttrs (name: mapAttrs (depType: filter (x: x != name)));
in
dir:

{
/* names maps dependency strings to derivations. It is a set of the form:
 * {
 *   <dependency name> = <derivation>
 * }
 */
  names
/* manifest lists the packages in the collection, their source and hash
 * information. It is a list of the form:
 * [
 *   {
 *     url = <src url>;
 *     sha256 = <hash>;
 *     name = <basename of src>;
 *     store = <store path of downloaded src>;
 *   }
 *   ...
 * ]
 * The package name is determined from the (sanitized) source name. This
 * is usually generated by ./manifest.sh
 */
, manifest
/* dependencies is a set of the form:
 * {
 *   <package attr name> = {
 *     buildInputs = [ <list of strings> ];
 *     nativeBuildInputs = [ <list of strings> ];
 *     propagatedBuildInputs = [ <list of strings> ];
 *     propagatedNativeBuildInputs = [ <list of strings> ];
 *     propagatedUserEnvPkgs = [ <list of strings> ];
 *   };
 *   ...
 * }
 * Each list of strings will be translated into dependencies using the
 * names argument. Every list must be present for each package, even if
 * it is just the empty list.
 */
, dependencies
/* extraInputs are attributes in the default scope (through callPackage) to
 * the expressions in the collection. They are not included in the final
 * set.
 */
, extraInputs ? {}
/* extraOutputs are extra attributes to include in the final set of the
 * collection. They are also used as extraInputs, so there is no need to
 * list packages twice.
 */
, extraOutputs ? {}
/* deriver is a function of two arguments. The first argument is an
 * attribute set of the form passed to stdenv.mkDerivation; these are the
 * default derivation attributes. The second argument is a list of attribute
 * sets which should be merged to produce additional arguments for the
 * derivation. The first arguments should override the merge arguments.
 */
, deriver ? mkDerivation
/* overrides is a set of extra attributes passed to the deriver for each
 * package, i.e., it is a set of the form:
 * {
 *    <package name> = { <extra attributes> };
 * }
 * The extra attributes can be any extra attributes for the deriver, such
 * as buildInputs, cmakeFlags, etc. They will be merged with attributes from
 * other sources.
 */
, overrides ? {}
}:
let dependenciesOrig = dependencies;
    dev = {
      inherit names;
      manifest = manifestXML manifest;
    };
in
let extraIn = extraOutputs // extraInputs // {
      inherit callPackage;
      mkDerivation = deriver;
      dev = dev // { inherit callPackage; };
    };
    extraOut = extraOutputs // {
      dev = dev // {
        inherit callPackage;
        mkDerivation = deriver;
        callAutonixPackage = callAutonixPackage callAutonixAttrs;
      };
    };
    callPackage = newScope (collection // extraIn);
    callAutonixAttrs = {
      inherit manifest overrides callPackage deriver;
      dependencies = breakRecursion dependenciesOrig;
      srcs = generateSources manifest;
      resolve = resolveInputs collection extraIn names;
    };
    collection =
      mapAttrs (n: p: callAutonixPackage callAutonixAttrs dir n {}) manifest;
in collection // extraOut
