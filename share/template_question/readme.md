# Stackoverflow
https://stackoverflow.com/questions/60220913/c-storing-plugin-interfaces

# Post

I'm trying to create a plugin manager for c++ that checks a directory for shared libraries (dll,so,dylib) and checks if there is a plugin interface available to store the plugin and retrieve it later with.

I'm using boost::dll to import the dll, but I don't know how to set up the template better.

How do I use templates or some other method to add plugin interfaces to the plugin manager so it will check the shared libraries for the export alias name and store the shared library handle?

PluginInterface.hpp
```cpp
class PluginInterface {
public:
  virtual void testPlugin() = 0;
};
```

plugin.hpp source for "plugins_directory/plugin.dll"
```cpp
#include <boost/config.hpp> // for BOOST_SYMBOL_EXPORT
#include "pluginInterface.hpp"

namespace PluginNamespace {
class PluginClass : public PluginInterface {
  void testPlugin(){
    printf("Hello World!");
  }
}

extern "C" BOOST_SYMBOL_EXPORT PluginClass pluginName;
PluginClass pluginName;
}
```

PluginManager.hpp
```cpp
class InterfaceMethodsBase {
public:
  std::string pluginName;
  InterfaceMethodsBase(std::string s) { pluginName = s; }
  ~InterfaceMethodsBase() {}
  virtual void addPath(std::filesystem::path p) = 0;
};

template <class T> class InterfaceMethods : public InterfaceMethodsBase {
public:
  InterfaceMethods(std::string s) : InterfaceMethodsBase(s) {}
  ~InterfaceMethods() {}
  std::vector<boost::shared_ptr<T>> pluginPtrs;
  void addPath(std::filesystem::path p) {
    boost::filesystem::path lib_path(p.string().c_str());
    std::cout << "PLUGIN: Loading " << p << "\n";
    boost::shared_ptr<T> plugin;
    try {
      plugin = boost::dll::import<T>(lib_path, pluginName,
                                     boost::dll::load_mode::default_mode);
    } catch (...) {
      std::cout << "PLUGIN: Loading FAILED " << p << "\n";
    }
    if (plugin) {
      std::cout << "PLUGIN: Loading SUCCESS " << p << "\n";
      pluginPtrs.push_back(plugin);
    }
  }
};

class PluginManager {
private:
  std::unordered_map<std::string, InterfaceMethodsBase *> interfaceMap;

public:
  template <class T> void addPluginInterface(std::string pluginName) {
    InterfaceMethods<T> *interface = new InterfaceMethods<T>(pluginName);
    InterfaceMethodsBase *interfaceBase = (InterfaceMethodsBase *)interface;
    interfaceMap.insert({pluginName, interface});
  }

  void loadPlugins(std::string directoryPathStr) {
    for (auto &p :
         std::filesystem::recursive_directory_iterator(directoryPathStr)) {
      std::cout << "PLUGIN: File Found " << p.path() << "\n";
      if (p.is_regular_file() &&
          (p.path().extension() == ".dll" || p.path().extension() == ".dylib" ||
           p.path().extension() == ".so")) {
        for (auto pairs : interfaceMap) {
          pairs.second->addPath(p.path());
        }
      }
    }
  }

  template <class T> boost::shared_ptr<T> getPlugin(std::string pluginName) {
    InterfaceMethods<T> *interface =
        dynamic_cast<InterfaceMethods<T> *>(interfaceMap.at(pluginName));
    if (interface->pluginPtrs.empty()) {
      return nullptr;
    }
    return interface->pluginPtrs.front();
  }
};
```

main.cpp
```cpp
#include "PluginManager.hpp"
#include "PluginInterface.hpp"

int main(){
  PluginManager pluginManagerObj;
  pluginManagerObj.addPluginInterface<PluginInterface>("pluginName");
  pluginManagerObj.loadPlugins("plugins_directory");
  boost::shared_ptr<PluginInterface> plugin = pluginManagerObj.getPlugin<PluginInterface>("pluginName");
  plugin->testPlugin();
}
```

EDIT: I'm using MinGW compiler on windows

# Answer 

My original intent was to find some way for the method `loadPlugins()` to intelligently find and load all plugins in a directory and store their handles for later use.

After asking the initial question and messing around with possible solutions, I found out I could use templates to create class `InterfaceMethods` that inherits `InterfaceMethodsBase` that would handle the recognition of a single interface type and store all the class instances in a hash table of type `InterfaceMethodsBase`. After calling `loadPlugins()`, I could retrieve the discovered plugins from the hash table.

I edited the working code back into the original post. I hope someone can benefit from this solution in the future.
