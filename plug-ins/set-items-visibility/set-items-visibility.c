/* This plug-in is a utility function that sets the visibility of a vector  */
/* list of layers, much faster than setting visibility per item via Script  */

#include "config.h"
#include <libgimp/gimp.h>
#include <libgimp/gimpui.h>
#include "stdplugins-intl.h"

#define PLUG_IN_PROC     _("pm-set-items-visibility")
#define PLUG_IN_BINARY   _("set-items-visibility")
#define PLUG_IN_VERSION  _("Aug 2023")

typedef struct _ItemVis      ItemVis;
typedef struct _ItemVisClass ItemVisClass;

struct _ItemVis
{
  GimpPlugIn parent_instance;
};

struct _ItemVisClass
{
  GimpPlugInClass parent_class;
};

#define ITEMVIS_TYPE (itemVis_get_type ())

GType                   itemVis_get_type         (void)                 G_GNUC_CONST;

static GList          * itemVis_query_procedures (GimpPlugIn           *plug_in);
static GimpProcedure  * itemVis_create_procedure (GimpPlugIn           *plug_in,
                                                  const gchar          *name);

static GimpValueArray * itemVis_run              (GimpProcedure        *procedure,
                                                  GimpRunMode           run_mode,
                                                  GimpImage            *image,
                                                  gint                  num_layers,
                                                  GimpDrawable        **drawables,
                                                  const GimpValueArray *args,
                                                  gpointer              run_data);

static void             itemVis                  (GimpImage            *image,
                                                  gint                  num_layers,
                                                  GimpDrawable        **drawables,
                                                  gint                  visible);


G_DEFINE_TYPE (ItemVis, itemVis, GIMP_TYPE_PLUG_IN)
GIMP_MAIN (ITEMVIS_TYPE)
DEFINE_STD_SET_I18N


static void
itemVis_class_init (ItemVisClass *klass)
{
  GimpPlugInClass *plug_in_class = GIMP_PLUG_IN_CLASS (klass);

  plug_in_class->query_procedures = itemVis_query_procedures;
  plug_in_class->create_procedure = itemVis_create_procedure;
  plug_in_class->set_i18n         = STD_SET_I18N;
}


static void
itemVis_init (ItemVis *itemVis)
{
}


static GList *
itemVis_query_procedures (GimpPlugIn *plug_in)
{
  return g_list_append (NULL, g_strdup (PLUG_IN_PROC));
}


static GimpProcedure *
itemVis_create_procedure (GimpPlugIn *plug_in, const gchar *name)
{
  GimpProcedure *procedure = NULL;

  if (! strcmp (name, PLUG_IN_PROC))
    {
      procedure = gimp_image_procedure_new (plug_in, name,
                                            GIMP_PDB_PROC_TYPE_PLUGIN,
                                            itemVis_run, NULL, NULL);

      gimp_procedure_set_image_types (procedure, "RGB*, GRAY*");
      gimp_procedure_set_sensitivity_mask (procedure,
                                           GIMP_PROCEDURE_SENSITIVE_DRAWABLE);

      gimp_procedure_set_documentation (procedure,
                                        _("Sets the visibility of a vector "
                                          "list of layers."),
                                        _("Sets the visibility of a vector "
                                          "list of layers."),
                                        name);

      gimp_procedure_set_attribution (procedure,
                                      "Mark Sweeney",
                                      "GNU GENERAL PUBLIC LICENSE Version 3",
                                      PLUG_IN_VERSION);

      gimp_procedure_add_argument (procedure,
                                   g_param_spec_int (_("visibility"),
                                                     _("the visibility state"),
                                                     _("the visibility state"),
                                                      0,1,0,
                                                      G_PARAM_READWRITE));
    }

  return procedure;
}


static GimpValueArray *
itemVis_run (GimpProcedure        *procedure,
             GimpRunMode           run_mode,
             GimpImage            *image,
             gint                  num_layers,
             GimpDrawable        **drawables,
             const GimpValueArray *args,
             gpointer              run_data)
{

  gegl_init (NULL, NULL);
  gint visible = GIMP_VALUES_GET_INT (args, 0);

  itemVis (image, num_layers, drawables, visible);

  return gimp_procedure_new_return_values (procedure, GIMP_PDB_SUCCESS, NULL);
}


static void
itemVis (GimpImage     *image,
         gint           num_layers,
         GimpDrawable **layers,
         gint           visible)
{

  for (gint i = 0; i < num_layers; i++) {
    gimp_item_set_visible(GIMP_ITEM(layers[i]), visible);
  }

}

