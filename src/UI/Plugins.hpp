/*
 * @name UC Davis PI Web API Browser
 * @author Branden Lee
 * @version 1.00
 * @license GNU LGPL v3
 * @brief Browser for UC Davis PI Web API data.
 *
 * Data from OSIsoft and UC Davis
 * Icons and images owned by their respective owners
 */

#ifndef UCDPWAB_PLUGINS_H
#define UCDPWAB_PLUGINS_H

// Universal Include
#include "universalInclude.hpp"

/*
 * UCDPWAB = UC Davis PI Web API Browser
 */
namespace UCDPWAB {

class PluginManager {
public:
  template <class T, char *str> void addPluginInterface() {
    std::filesystem::path p("lol");
    boost::filesystem::path lib_path(p.string().c_str());
    boost::shared_ptr<T> plugin;
    try {
      plugin = boost::dll::import<T>(lib_path, str,
                                     boost::dll::load_mode::default_mode);
    } catch (...) {
      std::cout << "PLUGIN: Loading FAILED " << p << "\n";
    }
  }
  void loadPlugins();
};

} // namespace UCDPWAB

#endif
// end UCDPWAB_PLUGINS_H
