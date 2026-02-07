# NVIDIA DGX-1 V100 Support (Branch: v100-support)

Cette branche est maintenue par **Morph3us Sigma** spécifiquement pour le support des GPUs **NVIDIA Tesla V100 (SM7.0)** sur l'infrastructure **NVIDIA DGX-1**.

## 🚀 Pourquoi cette branche ?

Bien que NCCL v2.29.3 supporte nativement l'architecture Volta (SM70), les binaires distribués ou compilés par défaut omettent souvent les kernels optimisés pour cette architecture afin de réduire la taille des binaires.

Sur un cluster DGX-1, nous avons besoin d'un build chirurgical qui :

1. Cible explicitement **SM70**.
2. Est lié à **CUDA 12.4+**.
3. Peut être utilisé via `LD_PRELOAD` pour optimiser les performances des frameworks LLM.

## 🛠️ Instructions de Build

Pour garantir la reproductibilité, utilisez le script de build dédié :

```bash
bash scripts/build_v100_dgx1.sh
```

Ou manuellement :

```bash
make -j src.build NVCC_GENCODE="-gencode=arch=compute_70,code=sm_70" CUDA_HOME=/usr/local/cuda-12.4
```

## 📝 Pourquoi pas de patch source ?

Il est de meilleure pratique de ne pas modifier le code source si le compilateur et les flags (`NVCC_GENCODE`) suffisent à activer le support.

- **Moins de maintenance** : Facilite les futurs rebasages sur le master de NVIDIA.
- **Clarté** : Sépare la **Logique** (Code) de la **Configuration** (Build flags).

Si des bugs liés au V100 sont découverts (ex: problèmes de `SymmMem`), les correctifs seront commités sur cette branche par **Morph3us Sigma**.
